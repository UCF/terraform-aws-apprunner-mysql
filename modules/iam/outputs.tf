output "apprunner_access_role_arn" {
  value       = aws_iam_role.apprunner_role.arn
  description = "The ARN of the AppRunner access IAM role"
}

output "github_access_role_arn" {
  value       = aws_iam_role.github_ecr_role.arn
  description = "The ARN of the ECR access IAM role"
}

output "oidc_arn" {
  value       = module.github-oidc.oidc_provider_arn
  description = "Github OIDC ARN"
}

output "apprunner_arn" {
  value = aws_iam_role.apprunner_role.arn
  description = "AppRunner IAM Role ARN"
}
