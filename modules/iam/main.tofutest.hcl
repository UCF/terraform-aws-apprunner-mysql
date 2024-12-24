##########################################################################
# main.tofutest.hcl                                                      #
##########################################################################
# Tests for main.tf                                                      #
##########################################################################

##########################################################################
# AppRunner IAM                                                          #
##########################################################################

run "apprunner_role_policy_document_has_correct_statement" {

  assert {
    condition     = contains([for principal in data.aws_iam_policy_document.apprunner_role_policy.statement[0].principals : principal.type], "Service")
    error_message = "Apprunner Role Principal Type is not Service"
  }

  assert {
    condition     = contains(flatten([for principal in data.aws_iam_policy_document.apprunner_role_policy.statement[0].principals : principal.identifiers]), "build.apprunner.amazonaws.com")
    error_message = "Apprunner Role Principal identifier is not build.apprunner.amazonaws.com"
  }

  assert {
    condition     = contains(data.aws_iam_policy_document.apprunner_role_policy.statement[0].actions, "sts:AssumeRole")
    error_message = "AppRunner Role Action is not sts:AssumeRole"
  }

  assert {
    condition     = data.aws_iam_policy_document.apprunner_role_policy.statement[0].effect == "Allow"
    error_message = "AppRunner Role Effect is not Allow"
  }
}

run "apprunner_role_assumes_correct_role_policy" {

  assert {
    condition     = jsondecode(resource.aws_iam_role.apprunner_role.assume_role_policy) == jsondecode(data.aws_iam_policy_document.apprunner_role_policy.json)
    error_message = "AppRunner role does not assume correct role policy."
  }
}

####i###################################################################
# ECR IAM Tests                                                        #
########################################################################

run "ecr_access_policy_document_has_correct_statement" {

  assert {
    condition     = contains(data.aws_iam_policy_document.ecr_access_policy.statement[0].resources, "*")
    error_message = "ECR Access Policy Document resources are not [\"*\"]."
  }

  assert {
    condition     = data.aws_iam_policy_document.ecr_access_policy.statement[0].effect == "Allow"
    error_message = "ECR Access Policy Document effect is not Allow."
  }

  assert {
    condition     = sort(tolist(data.aws_iam_policy_document.ecr_access_policy.statement[0].actions)) == sort(tolist(["ecr:GetDownloadUrlForLayer", "ecr:BatchGetImage", "ecr:BatchCheckLayerAvailability", "ecr:DescribeImages", "ecr:GetAuthorizationToken"]))
    error_message = "ECR Access Policy Document has incorrect actions."
  }
}

run "ecr_access_policy_assumes_correct_document" {

  assert {
    condition     = jsondecode(resource.aws_iam_policy.apprunner_ecr_access_policy.policy) == jsondecode(data.aws_iam_policy_document.apprunner_ecr_access_policy.json)
    error_message = "ECR Access Policy does not assume correct document."
  }
}

run "iam_role_policy_has_correct_attachments" {
  assert {
    condition     = resource.aws_iam_role_policy_attachment.apprunner_ecr_policy_attach.role == resource.aws_iam_role.apprunner_role.name
    error_message = "The ECR access policy is not attached to the correct IAM role"
  }

  assert {
    condition     = resource.aws_iam_role_policy_attachment.apprunner_ecr_policy_attach.policy_arn == resource.aws_iam_policy.apprunner_ecr_access_policy.arn
    error_message = "The policy ARN does not match the ECR access policy"
  }
}

######################################################################
# GitHub IAM Tests                                                   #
######################################################################

run "github_iam_has_correct_document_and_attachments" {
  assert {
    condition     = jsondecode(resource.aws_iam_policy.github_ecr_access.policy) == jsondecode(data.aws_iam_policy_document.githubecrdoc.json)
    error_message = "Github ECR Access Policy is not the proper policy document."
  }

  assert {
    condition     = resource.aws_iam_role_policy_attachment.github_ecraccess_attach.policy_arn == aws_iam_policy.github_ecr_access.arn
    error_message = "GitHub ECR Access not attached to IAM Role"
  }
}

#####################################################################
# ECS IAM Tests                                                     #
#####################################################################

run "ecs_iam_role_has_correct_name_and_policy" {
  assert {
    condition = resource.aws_iam_role.ecs_task_execution_role.name == "ecsTaskExecutionRole"
    error_message = "ECS IAM role does not have correct name"
  }

  assert {
    condition = jsondecode(resource.aws_iam_role.ecs_task_execution_role.assume_role_policy) == jsondecode(data.aws_iam_policy_document.ecs_task_execution.json)
    error_message = "ECS IAM policy does not have correct data."
  }

  assert {
    condition = contains(data.aws_iam_policy_document.ecs_task_execution.statement[0].actions, "sts:AssumeRole")
    error_message = "ECS IAM Policy Document does not have correct actions."
  }
  
  assert {
    condition     = contains([for principal in data.aws_iam_policy_document.ecs_task_execution.statement[0].principals : principal.type], "Service")
    error_message = "Apprunner Role Principal Type is not Service"
  }

  assert {
    condition     = contains(flatten([for principal in data.aws_iam_policy_document.ecs_task_execution.statement[0].principals : principal.identifiers]), "ecs-tasks.amazonaws.com")
    error_message = "Apprunner Role Principal identifier is not build.apprunner.amazonaws.com"
  }

}
