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
    error_message = "ECR access policy name is not 'apprunner-ecr-access-policy'"
  }

  assert {
    condition     = contains([for s in jsondecode(resource.aws_iam_policy.ecr_access_policy.policy).Statement[0].Action : s], "ecr:GetDownloadUrlForLayer")
    error_message = "ECR access policy does not include 'ecr:GetDownloadUrlForLayer'"
  }

  assert {
    condition     = contains([for s in jsondecode(resource.aws_iam_policy.ecr_access_policy.policy).Statement[0].Action : s], "ecr:GetAuthorizationToken")
    error_message = "ECR access policy does not include 'ecr:GetAuthorizationToken'"
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

run "github_iam" {
  assert {
    condition     = jsondecode(resource.aws_iam_policy.github_ecr_access.policy) == data.aws_iam_policy_document.githubecrdoc.json
    error_message = "Github ECR Access Policy is not the proper policy document."
  }

  assert {
    condition     = resource.aws_iam_role_policy_attachment.ecraccess_attach.policy_arn == aws_iam_policy.github_ecr_access.arn
    error_message = "GitHub ECR Access not attached to IAM Role"
  }
}
