output "ecr_repo_names" {
  description = "Names of ECR repositories"
  value       = values(aws_ecr_repository.repositories)[*].name
}
