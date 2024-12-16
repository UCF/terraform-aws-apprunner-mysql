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

  assert {
    condition     = data.aws_iam_policy_document.ecr_access_policy.statement[0].effect == "Allow"
    error_message = "ECR Access Policy Document does not have Allow effect."
  }
}

run "ecr_access_policy_assumes_correct_document" {

  assert {
    condition     = jsondecode(resource.aws_iam_policy.apprunner_ecr_access_policy.policy) == jsondecode(data.aws_iam_policy_document.ecr_access_policy.json)
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
    condition     = resource.aws_iam_role_policy_attachment.ecraccess_attach.policy_arn == aws_iam_policy.github_ecr_access.arn
    error_message = "GitHub ECR Access not attached to IAM Role"
  }
}


####################################################################
# Bastion IAM Tests                                                #
####################################################################


run "bastion_iam_policy_document_has_correct_statement" {
  assert {
    condition = contains([for principal in data.aws_iam_policy_document.session_manager_policy_document.statement[0].principals : principal.type], "Service") 
    error_message = "Bastion IAM Principal Type is not Service"
  }
 
  assert {
    condition = contains(flatten([for principal in data.aws_iam_policy_document.session_manager_policy_document.statement[0].principals : principal.identifiers]), "ec2.amazonaws.com")
    error_message = "Bastion IAM Principal Identifier is not ec2.amazonaws.com."
  }

  assert {
    condition = contains(data.aws_iam_policy_document.session_manager_policy_document.statement[0].actions, "sts:AssumeRole")
    error_message = "Bastion IAM Action is not sts:AssumeRole"
  }

  assert {
    condition = data.aws_iam_policy_document.session_manager_policy_document.statement[0].effect == "Allow"
    error_message = "Bastion IAM Effect is not Allow"
  }
}

run "bastion_iam_role_assumes_correct_policy_document" {
  assert {
    condition = jsondecode(resource.aws_iam_role.session_manager_role.assume_role_policy) == jsondecode(data.aws_iam_policy_document.session_manager_policy_document.json)
    error_message = "Bastion IAM role does not assume correct policy document"
  }
}
 
run "bastion_role_has_policies_attached" {
  assert {
    condition = resource.aws_iam_role_policy_attachment.session_manager_attachment.role == resource.aws_iam_role.session_manager_role.name
    error_message = "Bastion IAM role policy attachment connected to correct role"
  }
}

run "ssm_start_policy_document_has_correct_statement" {
  assert {
    condition = data.aws_iam_policy_document.ssm_start_policy_document.statement[0].effect == "Allow"
    error_message = "SSM Start Policy Document does not assume correct Effect, Allow"
  }

  assert {
    condition = contains(data.aws_iam_policy_document.ssm_start_policy_document.statement[0].resources, "*")
    error_message = "SSM Start Policy Document does not assume correct resource, *"
  }

  assert {
    condition = sort(tolist(data.aws_iam_policy_document.ssm_start_policy_document.statement[0].actions)) == sort(tolist(["ssm:StartSession", "ssm:DescribeSession", "ssm:TerminateSession"]))
    error_message = "SSM Start Policy Document does not assume correct actions"
  }
}


