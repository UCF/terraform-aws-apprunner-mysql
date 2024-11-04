output "rds_endpoint" {
  value = aws_db_instance.default.endpoint
}

output "vpc_connector_arn" {
  value = aws_apprunner_vpc_connector.app_vpc_connector.arn
}
