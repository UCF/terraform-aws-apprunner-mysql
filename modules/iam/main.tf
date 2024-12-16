######################################################################################
# main.tf                                                                            #
######################################################################################
# IAM access policies, roles, etc. More information on access                        #
# policies here:                                                                     #
# https://docs.aws.amazon.com/apprunner/latest/dg/security_iam_service-with-iam.html #
######################################################################################
# AppRunner IAM                                                                      #
######################################################################################

data "aws_iam_policy_document" "apprunner_role_policy" {
  statement {
    principals {
      type        = "Service"
      identifiers = ["build.apprunner.amazonaws.com"]
    }
    actions = ["sts:AssumeRole"]
    effect  = "Allow"
  }
}

resource "aws_iam_role" "apprunner_role" {
  name               = "apprunner-access-role"
  assume_role_policy = data.aws_iam_policy_document.apprunner_role_policy.json
}

#####################################################################################
# AppRunner and ECR                                                                 #
#####################################################################################

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
  name   = "apprunner-ecr-access-policy"
  policy = data.aws_iam_policy_document.ecr_access_policy.json
}


resource "aws_iam_role_policy_attachment" "apprunner_ecr_policy_attach" {
  role       = aws_iam_role.apprunner_role.name
  policy_arn = aws_iam_policy.apprunner_ecr_access_policy.arn
}

######################################################################################
# GitHub ECR Access                                                                  #
######################################################################################

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
      values   = ["repo:UCF/*:*"]
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

######################################################################################
# Bastion IAM                                                                        #
######################################################################################

data "aws_iam_policy_document" "session_manager_policy_document" {
  statement {
    principals {
      type = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
    actions = ["sts:AssumeRole"]
    effect = "Allow"
  }
}

data "aws_iam_policy_document" "ssm_start_policy_document" {
  statement {
    resources = ["*"]
    actions = ["ssm:StartSession", "ssm:DescribeSession", "ssm:TerminateSession"]
    effect = "Allow"
  }
} 

resource "aws_iam_role" "session_manager_role" {
  name = "bastion-session-manager-role"
  assume_role_policy = data.aws_iam_policy_document.session_manager_policy_document.json
}

resource "aws_iam_role_policy_attachment" "session_manager_attachment" {
  role = aws_iam_role.session_manager_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore" 
  depends_on = [aws_iam_role.session_manager_role]
}

resource "aws_iam_policy" "ssm_start_policy" {
  name = "ssm-start-session-policy"
  description = "Policy to start SSM sessions"
  policy = data.aws_iam_policy_document.ssm_start_policy_document.json 
} 

resource "aws_iam_role_policy_attachment" "attach_ssm_policy" {
  role = aws_iam_role.session_manager_role.name
  policy_arn = aws_iam_policy.ssm_start_policy.arn
}

resource "aws_iam_instance_profile" "session_manager_profile" {
  name = "session-manager-profile"
  role = aws_iam_role.session_manager_role.name
  depends_on = [aws_iam_role.session_manager_role]
}

resource "aws_iam_instance_profile" "bastion_ssm_profile" {
  name = "bastion-ssm-instance-profile"
  role = aws_iam_role.session_manager_role.name
}
