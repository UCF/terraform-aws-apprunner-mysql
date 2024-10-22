output "apprunner_access_role_arn" {
  value = aws_iam_role.apprunner_role.arn
  description = "The ARN of the AppRunner access IAM role"
}
