output "ecr_repo_names" {
  description = "Names of ECR repositories"
  value       = values(aws_ecr_repository.repositories)[*].name
}

output "ecr_timestamp" {
  description = "Timestamp of ecr repos"
  value = local.timestamp_sanitized
}
