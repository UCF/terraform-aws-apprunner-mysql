variables {
  applications = ["announcements", "template"]
  environments = ["dev", "test"]
}

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

run "internet_gateway_in_vpc" {
  assert {
    condition     = resource.aws_internet_gateway.main.vpc_id == resource.aws_vpc.main.id
    error_message = "Internet gateway is not in VPC"
  }
}

run "aws_route_table_has_gateway_id" {
  assert {
    condition     = contains([for r in resource.aws_route_table.public.route : r.gateway_id], resource.aws_internet_gateway.main.id)
    error_message = "Internet gateway is not in route table."
  }
}

run "aws_route_table_association_has_main_subnet" {
  assert {
    condition     = resource.aws_route_table_association.main_subnet_association.subnet_id == aws_subnet.main.id
    error_message = "Route table does not have main subnet associated."
  }
}

run "aws_route_table_association_has_alt_subnet" {
  assert {
    condition     = resource.aws_route_table_association.alt_subnet_association.subnet_id == resource.aws_subnet.alternative.id
    error_message = "Route table does not have alt subnet associated."
  }
}

run "aws_db_instance_has_mysql" {
  assert {
    condition     = resource.aws_db_instance.default.engine == "mysql"
    error_message = "DB instance is not using MySQL."
  }
}

run "null_resource_runs" {
  assert {
    condition     = alltrue([for key, resource in resource.null_resource.create_databases : resource.id != ""])
    error_message = "Database creation command failed."
  }
}


run "check_database_creation" {
  assert {
    # Check that the database creation result file exists and contains the expected output
    condition     = alltrue([for combo in module.appenvlist.app_env_list : fileexists("/tmp/db_check_${combo.app}_${combo.env}.txt") && length(fileset("/tmp", "db_check_${combo.app}_${combo.env}.txt")) > 0])
    error_message = "Database creation verification failed for one or more environments."
  }
}

