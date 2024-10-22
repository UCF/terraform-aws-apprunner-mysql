output "rds_endpoint" {
  value = aws_db_instance.default.endpoint
}

output "db_password" {
  value = resource.aws_db_instance.default.password
  sensitive = true
}
