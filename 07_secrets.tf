data "aws_iam_policy_document" "workload_identity_policy" {
  statement {
    effect = "Allow"
    actions = [
      "secretsmanager:GetSecretValue",
      "secretsmanager:DescribeSecret",
    ]
    resources = [ 
      "arn:aws:secretmanager:${var.primary_region}:${data.aws_caller_identity.current.account_id}:secret:*",
    ]
  }
}

resource "aws_secretsmanager_secret" "db_credentials" {
  name = "${var.application_name}-${var.environment_name}-connection-string"
  description = "Database connection string"
}

resource "aws_secretsmanager_secret_version" "db_credentials_version" {
  secret_id = aws_secretsmanager_secret.db_credentials.id
  secret_string = jsonencode({
    username = var.db_username
    password = var.db_password
  })
}

resource "helm_release" "csi_secrets_store" {
  name = "csi-secrets-store"
  repository = "https://kubernetes-sigs.github.io/secrets-stroe-csi-driver/charts"
  chart = "secrets-store-csi-driver"
  namespace = "kube-system"

  set {
    name = "syncSecret.enabled"
    value = "true"
  }
}

resource "helm_release" "aws_secrets_proviver" {
  name = "secrets-provider-aws"
  repository = "https://aws.github.io/secrets-store-csi-driver-provider-aws"
  chart = "secrets-store-csi-driver-provider-aws"
  namespace = "kube-system"
}

