run "aws_iam_role_apprunner_role" {
  assert {
    condition     = resource.aws_iam_role.apprunner_role.name == "apprunner-access-role"
    error_message = "AppRunner role name does not match"
  }

  assert {
    condition     = jsondecode(resource.aws_iam_role.apprunner_role.assume_role_policy).Statement[0].Principal.Service == "build.apprunner.amazonaws.com"
    error_message = "AppRunner role assume_role_policy is incorrect"
  }
}

run "aws_iam_policy_ecr_access_policy" {
  assert {
    condition     = resource.aws_iam_policy.ecr_access_policy.name == "apprunner-ecr-access-policy"
    error_message = "ECR access policy name does not match"
  }

  assert {
    condition     = contains([for s in jsondecode(resource.aws_iam_policy.ecr_access_policy.policy).Statement[0].Action : s], "ecr:GetDownloadUrlForLayer")
    error_message = "ECR access policy does not include 'ecr:GetDownloadUrlForLayer'"
  }

  assert {
    condition     = jsondecode(resource.aws_iam_policy.ecr_access_policy.policy).Statement[1].Action == "ecr:GetAuthorizationToken"
    error_message = "ECR access policy does not include 'ecr:GetAuthorizationToken'"
  }
}

run "check_ecr_public_permissions" {
  assert {
    # Check if 'ecr-public:GetDownloadUrlForLayer' is included in the first statement
    condition     = contains([for action in jsondecode(resource.aws_iam_policy.ecr_access_policy.policy).Statement[2].Action : action], "ecr-public:GetDownloadUrlForLayer")
    error_message = "'ecr-public:GetDownloadUrlForLayer' permission is missing in the first statement."
  }

  assert {
    # Check if 'ecr-public:BatchCheckLayerAvailability' is included in the first statement
    condition     = contains([for action in jsondecode(resource.aws_iam_policy.ecr_access_policy.policy).Statement[2].Action : action], "ecr-public:BatchCheckLayerAvailability")
    error_message = "'ecr-public:BatchCheckLayerAvailability' permission is missing in the first statement."
  }

  assert {
    # Check if 'ecr-public:BatchGetImage' is included in the first statement
    condition     = contains([for action in jsondecode(resource.aws_iam_policy.ecr_access_policy.policy).Statement[2].Action : action], "ecr-public:BatchGetImage")
    error_message = "'ecr-public:BatchGetImage' permission is missing in the first statement."
  }

  assert {
    # Check if 'ecr-public:DescribeRepositories' is included in the first statement
    condition     = contains([for action in jsondecode(resource.aws_iam_policy.ecr_access_policy.policy).Statement[2].Action : action], "ecr-public:DescribeRepositories")
    error_message = "'ecr-public:DescribeRepositories' permission is missing in the first statement."
  }

  assert {
    # Check if 'ecr-public:GetRepositoryPolicy' is included in the first statement
    condition     = contains([for action in jsondecode(resource.aws_iam_policy.ecr_access_policy.policy).Statement[2].Action : action], "ecr-public:GetRepositoryPolicy")
    error_message = "'ecr-public:GetRepositoryPolicy' permission is missing in the first statement."
  }

  assert {
    # Check if 'ecr-public:ListTagsForResource' is included in the first statement
    condition     = contains([for action in jsondecode(resource.aws_iam_policy.ecr_access_policy.policy).Statement[2].Action : action], "ecr-public:ListTagsForResource")
    error_message = "'ecr-public:ListTagsForResource' permission is missing in the first statement."
  }

  assert {
    # Check if 'ecr-public:DescribeImages' is included in the first statement
    condition     = contains([for action in jsondecode(resource.aws_iam_policy.ecr_access_policy.policy).Statement[2].Action : action], "ecr-public:DescribeImages")
    error_message = "'ecr-public:DescribeImages' permission is missing in the first statement."
  }

  assert {
    # Check if 'ecr-public:ListImages' is included in the first statement
    condition     = contains([for action in jsondecode(resource.aws_iam_policy.ecr_access_policy.policy).Statement[2].Action : action], "ecr-public:ListImages")
    error_message = "'ecr-public:ListImages' permission is missing in the first statement."
  }

  assert {
    # Check if 'ecr-public:GetAuthorizationToken' is included in the second statement
    condition     = jsondecode(resource.aws_iam_policy.ecr_access_policy.policy).Statement[3].Action == "ecr-public:GetAuthorizationToken"
    error_message = "'ecr-public:GetAuthorizationToken' permission is missing in the second statement."
  }
}


run "iam_role_policy_attachments" {
  assert {
    condition     = resource.aws_iam_role_policy_attachment.apprunner_ecr_policy_attach.role == resource.aws_iam_role.apprunner_role.name
    error_message = "The ECR access policy is not attached to the correct IAM role"
  }

  assert {
    condition     = resource.aws_iam_role_policy_attachment.apprunner_ecr_policy_attach.policy_arn == resource.aws_iam_policy.ecr_access_policy.arn
    error_message = "The policy ARN does not match the ECR access policy"
  }
}
