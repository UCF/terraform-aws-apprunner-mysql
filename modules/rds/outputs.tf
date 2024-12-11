output "rds_endpoint" {
  value = aws_db_instance.default.endpoint
}

output "bastion_instance_id" {
  value = aws_instance.bastion.id
}
