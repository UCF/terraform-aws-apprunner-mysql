######################################################################################
# main.tf                                                                            #
######################################################################################
# More information on access policies can be found at                                #
# https://docs.aws.amazon.com/apprunner/latest/dg/security_iam_service-with-iam.html #
######################################################################################

data "aws_caller_identity" "current" {}

###################################################################
# Github and ECR Access Policies                                  #
###################################################################

resource "aws_iam_policy" "github_ecr_access_policy" {
  name = "github-ecr-access-policy"
  policy = data.aws_iam_policy_document.github_ecr_get_image_policy.json
}

data "aws_iam_policy_document" "github_ecr_get_image_policy" {
  statement {
    resources = ["*"]
    effect = "Allow"
    actions = [
      "ecr:GetDownloadUrlForLayer",
      "ecr:BatchGetImage", 
      "ecr:BatchCheckLayerAvailability",
      "ecr:DescribeImages",
      "ecr:GetAuthorizationToken"
    ]
  }
}

resource "aws_iam_role_policy_attachment" "github_ecr_policy_attach" {
  role       = aws_iam_role.github_ecr_role.name
  policy_arn = aws_iam_policy.github_ecr_access.arn
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
      type        = "Federated"
      identifiers = [module.github-oidc.oidc_provider_arn]
    }
    condition {
      test     = "StringLike"
      variable = "token.actions.githubusercontent.com:sub"
      values   = var.github_actions_values
    }
  }
}

resource "aws_iam_role" "github_ecr_role" {
  name               = "GitHubAction-AssumeRoleWithAction"
  assume_role_policy = data.aws_iam_policy_document.github_actions_assume_role.json
}

resource "aws_iam_role_policy_attachment" "github_ecraccess_attach" {
  role       = aws_iam_role.github_ecr_role.name
  policy_arn = aws_iam_policy.github_ecr_access.arn
}

module "github-oidc" {
  source = "github.com/terraform-module/terraform-aws-github-oidc-provider?ref=v2.2.1"

  create_oidc_provider = true
  create_oidc_role     = false

  repositories              = [var.github_oidc_repositories]
  oidc_role_attach_policies = [aws_iam_policy.github_ecr_access.arn]
}

data "aws_iam_policy_document" "ecr_access_policy" {
  statement {
    resources = ["*"]
    actions = [
      "ecr:GetDownloadUrlForLayer",
      "ecr:BatchGetImage", 
      "ecr:BatchCheckLayerAvailability", 
      "ecr:DescribeImages",
      "ecr:GetAuthorizationToken"
    ]
  }
}


##############################################################
# AppRunner access policies                                  #
##############################################################

resource "aws_iam_role" "apprunner_role" {
  name = "apprunner-assume-role"
  assume_role_policy = data.aws_iam_policy_document.apprunner_role_policy.json
}

data "aws_iam_policy_document" "apprunner_role_policy" {
  statement {
    effect = "Allow"
    actions = [
      "sts:AssumeRole",
    ]
  principals {
      type = "Service"
      identifiers = ["build.apprunner.amazonaws.com"]
    }
  }
}

# Policy for ECR access (allow AppRunner to pull images from ECR)
resource "aws_iam_role_policy" "apprunner_permissions_policy" {
  role = aws_iam_role.apprunner_role.name
  policy = data.aws_iam_policy_document.apprunner_permissions_policy.json
}

data "aws_iam_policy_document" "apprunner_permissions_policy" {
  statement {
    actions = [
      "ecr:GetAuthorizationToken",
      "ecr:BatchGetImage",
      "ecr:BatchCheckLayerAvailability",
    ]
    resources = [
      "arn:aws:ecr:${var.region}:${data.aws_caller_identity.current.account_id}:repository/*"
    ]
  }
}

# Policy for AppRunner to interact with ECR
resource "aws_iam_policy" "apprunner_ecr_access_policy" {
  policy = data.aws_iam_policy_document.apprunner_ecr_access_policy.json
}

data "aws_iam_policy_document" "apprunner_ecr_access_policy" {
  statement {
    actions = ["sts:AssumeRole"]
    resources = ["*"]
  }
}

# Attach ECR acess policy to AppRunner role
resource "aws_iam_role_policy_attachment" "apprunner_ecr_policy_attach" {
  role = resource.aws_iam_role.apprunner_role.name
  policy_arn = resource.aws_iam_policy.apprunner_ecr_access_policy.arn
}


