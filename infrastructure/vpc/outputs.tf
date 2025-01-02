output "vpc_connector_arn" {
  value = aws_apprunner_vpc_connector.app_vpc_connector.arn
}

output "subnet_id" {
  value = aws_subnet.nat_subnet.id
}

output "rds_secgrp_id" {
  value = aws_security_group.rds_secgrp.id
}

output "db_sg_name" {
  value = aws_db_subnet_group.default.name
}

output "bastion_sg_id" {
  value = aws_security_group.bastion_sg.id
}
