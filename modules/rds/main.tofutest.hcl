run "vpc_dns" {
  assert {
    condition     = resource.aws_vpc.main.enable_dns_support == true && resource.aws_vpc.main.enable_dns_hostnames == true
    error_message = "DNS Support not enabled"
  }
}

run "public_subnets" {
  assert {
    condition     = resource.aws_subnet.main.map_public_ip_on_launch == true && resource.aws_subnet.alternative.map_public_ip_on_launch == true
    error_message = "Subnets not mapped to public IP on launch"
  }
}

run "subnets_group_has_ids" {
  assert {
    condition     = contains(resource.aws_db_subnet_group.default.subnet_ids, resource.aws_subnet.main.id) && contains(resource.aws_db_subnet_group.default.subnet_ids, resource.aws_subnet.alternative.id)
    error_message = "Subnet group does not have public subnets as subnet ids"
  }
}

run "aws_security_group_in_vpc" {
  assert {
    condition     = resource.aws_security_group.rds_secgrp.vpc_id == resource.aws_vpc.main.id
    error_message = "Security group is not in VPC"
  }
}
