locals {
  cluster_name       = "eks-${var.application_name}-${var.environment_name}"
  cluster_subnet_ids = [for subnet in values(aws_subnet.backend) : subnet.id]
}

resource "aws_cloudwatch_log_group" "container_cluster" {
  name              = "/aws/eks/${local.cluster_name}/cluster"
  retention_in_days = 7
}


resource "aws_eks_cluster" "main" {
  name                      = local.cluster_name
  role_arn                  = aws_iam_role.container_cluster.arn
  enabled_cluster_log_types = ["api", "audit"]

  vpc_config {

    security_group_ids = [
      aws_security_group.cluster.id,
      aws_security_group.cluster_nodes.id
    ]

    subnet_ids              = local.cluster_subnet_ids
    endpoint_public_access  = true
    endpoint_private_access = true
  }

  depends_on = [
    aws_iam_role_policy_attachment.eks_cluster_policy,
    aws_iam_role_policy_attachemetn.eks_vpc_controller_policy,
    aws_cloudwatch_log_group.container_cluster,
    aws_ecr_repository.main
  ]

  tags = {
    application = var.applications_name
    environment = var.envrionment_name
  }
}

resource "aws_eks_node_group" "main" {

  cluster_name    = aws_eks_cluster.main.name
  node_group_name = "ng-user"
  node_role_arn   = aws_iam_role.container_node_group.arn
  subnet_ids      = local.cluster_subnet_ids

  scaling_config {
    desired_size = 3
    min_size     = 1
    max_size     = 4
  }

  update_config {
    max_unavailable = 1
  }

  ami_type       = var.node_image_type
  instance_types = [var.node_size]

  depends_on = [
    aws_iam_role_policy_attachment.eks_worker_node_policy,
    aws_iam_role_policy_attachment.eks_cni_policy,
    aws_iam_role_policy_attachment.eks_ecr_policy,
    aws_iam_role_policy_attachment.eks_cloudwatch_policy
  ]
}

data "tls_certificate" "container_cluster_oidc" {
  url = aws_eks_cluster.main.identity[0].oidc[0].issuer
}

resource "aws_iam_openid_connect_provider" "container_cluster_oidc" {
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = [data.tls_certificate.container_cluster_oidc.certificates[0].sha1_fingerprint]
  url             = data.tls_certificate.container_cluster_oidc.url
}

data "aws_iam_policy_document" "workload_identity_assume_role_policy" {
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]
    effect  = "Allow"
    condition {
      test     = "StringEquals"
      variable = "${replace(aws_iam_openid_connect_provider.container_cluster_oidc.url, "https://", "")}:sub"
      values   = ["system:serviceaccount:${var.k8s_namespace}:${var.k8s_service_account_name}"]
    }
    principals {
      identifiers = [aws_iam_openid_connect_provider.container_cluster_oidc.arn]
      type        = "Federated"
    }
  }
}

resource "kubernetes_namespace" "main" {
  metadata {
    name = var.namespace
    labels = {
      name = var.namespace
    }
  }
}

resource "kubernetes_service_account" "workload_identity" {
  for_each = { for k, v in var.namespaces : k => v }
  metadata {
    name      = "${each.value[0]}_service_account"
    namespace = each.value[0]
    annotations = {
      "eks.amazonaws.com/role-arn" = var.workload_identity_role
    }
  }
}

resource "kubernetes_manifest" "secret_provider_class" {
  manifest = {
    apiVersion = "secrets-store.csi.x-k8s.io/v1"
    kind       = "SecretProviderClass"

    metadata = {
      name      = "${var.application_name}-${var.environment_name}-secret-provider-class"
      namespace = var.namespace
    }

    spec = {
      provider = "aws"
      parameters = {
        objects = yamlencode([
          {
            objectName         = "connection-string"
            objectType         = "secretsmanager"
            objectVersionLabel = "AWSCURRENT"
          }
        ])
      }
      secretObjects = [
        {
          data = [
            {
              key        = "connection-string"
              objectName = "connection-string"
            }
          ]
          secretName = "connection-string"
          type       = "Opaque"
        }
      ]
    }
  }
}

resource "aws_iam_policy" "workload_identity" {

  name        = "${var.application_name}-${var.environment_name}-workload-identity"
  description = "Policy for ${var.application_name}-${var.environment_name} Workload Identity"
  policy      = data.aws_iam_policy_document.workload_identity_policy.json

}

resource "aws_iam_role" "workload_identity" {
  assume_role_policy = data.aws_iam_policy_document.workload_identity_assume_role_policy.json
  name               = "${var.application_name}-${var.environment_name}-workload-identity"
}
