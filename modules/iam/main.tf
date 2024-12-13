data "aws_caller_identity" "current" {}

data "aws_iam_policy_document" "apprunner_role_policy" {
  statement {
    principals {
      type = "Service"
      identifiers = ["build.apprunner.amazonaws.com"] 
    }
    actions = ["sts:AssumeRole"]  
    effect = "Allow"
  }
}

resource "aws_iam_role" "apprunner_role" {
 name = "apprunner-access-role"
 assume_role_policy = data.aws_iam_policy_document.apprunner_role_policy.json 
}

# More information on access policies at https://docs.aws.amazon.com/apprunner/latest/dg/security_iam_service-with-iam.html

data "aws_iam_policy_document" "ecr_access_policy" {
  statement {
    resources = ["*"]
    actions = [
      "ecr:GetDownloadUrlForLayer",
      "ecr:BatchGetImage",
      "ecr:BatchCheckLayerAvailability",
      "ecr:DescribeImages",
      "ecr:GetAuthorizationToken",
    ]
    effect = "Allow"
  }
}

resource "aws_iam_policy" "apprunner_ecr_access_policy" {
  name = "apprunner-ecr-access-policy"
  policy = data.aws_iam_policy_document.ecr_access_policy.json
}


resource "aws_iam_role_policy_attachment" "apprunner_ecr_policy_attach" {
  role       = aws_iam_role.apprunner_role.name
  policy_arn = aws_iam_policy.apprunner_ecr_access_policy.arn
}

resource "aws_iam_policy" "github_ecr_access" {
  name   = "GitHubECRAccess"
  policy = data.aws_iam_policy_document.githubecrdoc.json
}

data "aws_iam_policy_document" "githubecrdoc" {
  statement {
    actions = [
      "ecr:BatchGetImage",
      "ecr:BatchCheckLayerAvailability",
      "ecr:CompleteLayerUpload",
      "ecr:GetDownloadUrlForLayer",
      "ecr:InitiateLayerUpload",
      "ecr:PutImage",
      "ecr:UploadLayerPart",
    ]
    resources = ["arn:aws:ecr:*:*:repository/*"]
  }

  statement {
    actions   = ["ecr:GetAuthorizationToken"]
    resources = ["*"]
  }
}

data "aws_iam_policy_document" "github_actions_assume_role" {
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]
    principals {
      type = "Federated"
      identifiers = [module.github-oidc.oidc_provider_arn]
    }
    condition {
      test = "StringLike"
      variable = "token.actions.githubusercontent.com:sub"
      values = ["repo:UCF/*:*"]
    }
  }
}

resource "aws_iam_role" "ecraccess_role" {
  name               = "GitHubAction-AssumeRoleWithAction"
  assume_role_policy = data.aws_iam_policy_document.github_actions_assume_role.json 
}

resource "aws_iam_role_policy_attachment" "ecraccess_attach" {
  role       = aws_iam_role.ecraccess_role.name
  policy_arn = aws_iam_policy.github_ecr_access.arn
}

module "github-oidc" {
  source = "github.com/terraform-module/terraform-aws-github-oidc-provider"

  create_oidc_provider = true
  create_oidc_role     = false

  repositories              = ["UCF/*"]
  oidc_role_attach_policies = ["${aws_iam_policy.github_ecr_access.arn}"]
}
