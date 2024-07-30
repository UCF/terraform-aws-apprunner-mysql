locals {
  cluster_name = "eks-${var.application_name}-${var.environment_name}"
  cluster_subnet_ids = [for subnet in values(aws_subnet.backend) : subnet.id]
}

data "aws_eks_cluster" "cluster" {
  name = var.eks_cluster_name
}

resource "aws_eks_cluster" "main" {
  name = local.cluster_name
  role_arn = aws_iam_role.container_cluster.arn
  enabled_cluster_log_types = ["api", "audit"]

  vpc_config {
    
    security_group_ids = [
      aws_security_group.cluster.id,
      aws_security_group.cluster_nodes.id
    ]

    subnet_ids = local.cluster_subnet_ids
    endpoint_public_access = true
    endpoint_private_access = true
  }

  depends_on = [
    aws_iam_role_policy_attachment.eks_cluster_policy,
    aws_iam_role_policy_attachemetn.eks_vpc_controller_policy,
    aws_cloudwatch_log_group.container_cluster,
    aws_ecr_repository.main.*
  ]

  tags = {
    application = var.applications_name
    environment = var.envrionment_name
  }
}

resource "aws_eks_node_group" "main" {

  cluster_name = aws_eks_cluster.main.name
  node_group_name = "ng-user"
  node_role_arn = aws_iam_role.container_node_group.arn
  subnet_ids = local.cluster_subnet_ids
  
  scaling_config {
    desired_size = 3
    min_size = 1
    max_size = 4
  }
  
  update_config {
    max_unavailable = 1
  }  

  ami_type = var.node_image_type
  instance_types = [var.node_size]

  depends_on = [
    aws_iam_role_policy_attachment.eks_worker_node_policy,
    aws_iam_role_policy_attachment.eks_cni_policy,
    aws_iam_role_policy_attachment.eks_ecr_policy,
    aws_iam_role_policy_attachment.eks_cloudwatch_policy
  ]
}

resource "aws_cloudwatch_log_group" "container_cluster" {
  name = "/aws/eks/${local.cluster_name}/cluster"
  retention_in_days = 7
}

data "tls_certificate" "container_cluster_oidc" {
  url = aws_eks_cluster.main.identity[0].oidc[0].issuer
}

resource "aws_iam_openid_connect_provider" "container_cluster_oidc" {
  client_id_list = ["sts.amazonaws.com"]
  thumbprint_list = [data.tls_certificate.container_cluster_oidc.certificates[0].sha1_fingerprint]
  url = data.tls_certificate.container_cluster_oidc.url
}

data "aws_iam_policy_document" "workload_identity_assume_role_policy" {
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]
    effect = "Allow"
    condition {
      test = "StringEquals"
      variable = "${replace(aws_iam_openid_connect_provider.container_cluster_oidc.url, "https://", "")}:sub"
      values = ["system:serviceaccount:${var.k8s_namespace}:${var.k8s_service_account_name}"]
    }
    principals {
      identifiers = [aws_iam_openid_connect_provider.container_cluster_oidc.arn]
      type = "Federated"
    }
  }
}


