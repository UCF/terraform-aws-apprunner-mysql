output "apprunner_access_role_arn" {
  value       = aws_iam_role.apprunner_role.arn
  description = "The ARN of the AppRunner access IAM role"
}

output "github_access_role_arn" {
  value       = aws_iam_role.ecraccess_role.arn
  description = "The ARN of the ECR access IAM role"
}

output "oidc_arn" {
  value       = module.github-oidc.oidc_provider_arn
  description = "Github OIDC ARN"
}

output "bastion_ssm_profile" {
  value = aws_iam_instance_profile.bastion_ssm_profile.id
}
