####################################################################
# main.tf                                           		   #
####################################################################
# Creates necessary AWS infrastructure for an RDS MySQL instance.  #
####################################################################

####################################################################
# VPC   							   #
####################################################################

resource "aws_vpc" "main" {
  cidr_block           = ["10.0.0.0/16"]
  enable_dns_support   = true
  enable_dns_hostnames = true
}

resource "aws_apprunner_vpc_connector" "app_vpc_connector" {
  vpc_connector_name = "app-vpc-connector"
  subnets            = [aws_subnet.main.id, aws_subnet.alternative.id]
  security_groups    = [aws_security_group.apprunner_sg.id]
}

resource "aws_flow_log" "vpc_flow_logs" {
  vpc_id          = aws_vpc.main.id
  log_destination = aws_cloudwatch_log_group.vpc_flow_logs.arn
  traffic_type    = "ALL"
}

resource "aws_cloudwatch_log_group" "vpc_flow_logs" {
  name              = "/aws/vpc/flow-logs"
  retention_in_days = 30
}

###################################################################
# Subnets and subnet group                                        #
###################################################################

resource "aws_subnet" "main" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "us-east-1c"
  map_public_ip_on_launch = false
}

resource "aws_subnet" "alternative" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.2.0/24"
  availability_zone       = "us-east-1b"
  map_public_ip_on_launch = false
}

resource "aws_subnet" "nat_subnet" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.3.0/24"
  availability_zone       = "us-east-1d"
  map_public_ip_on_launch = true
}

resource "aws_db_subnet_group" "default" {
  name       = "default-subnet-group"
  subnet_ids = [aws_subnet.main.id, aws_subnet.alternative.id]
}

################################################################
# Security groups 					       #
################################################################                    
resource "aws_security_group" "rds_secgrp" {
  vpc_id = aws_vpc.main.id

  ingress {
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = [aws_vpc.main.cidr_block]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "apprunner_sg" {
  vpc_id = aws_vpc.main.id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group_rule" "apprunner_to_rds" {
  type                     = "ingress"
  from_port                = 3306
  to_port                  = 3306
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.apprunner_sg.id
  security_group_id        = aws_security_group.rds_secgrp.id
}

##################################################################
# Internet and NAT Gateways                                      #
##################################################################

resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id
}

resource "aws_eip" "nat_eip" {
  domain     = "vpc"
  depends_on = [aws_internet_gateway.main]
}

resource "aws_nat_gateway" "nat" {
  allocation_id = aws_eip.nat_eip.id
  subnet_id     = aws_subnet.nat_subnet.id
}

#################################################################
# Route table and associations                                  #
#################################################################

resource "aws_route_table" "private" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.nat.id
  }
}

resource "aws_route_table_association" "private_main_association" {
  subnet_id      = aws_subnet.main.id
  route_table_id = aws_route_table.private.id
}

resource "aws_route_table_association" "private_alt_association" {
  subnet_id      = aws_subnet.alternative.id
  route_table_id = aws_route_table.private.id
}

################################################################
# Random password for tofu test db                             #
################################################################

resource "random_password" "password" {
  length           = 16
  special          = true
  override_special = "#&*=+:?"
}

###############################################################
# RDS instance, app DBs, users, and permission grants         #
###############################################################

resource "aws_db_instance" "default" {
  identifier        = "cm-appfolio-db"
  allocated_storage = 20
  engine            = "mysql"
  engine_version    = "8.0"
  instance_class    = "db.t3.micro"
  username          = "admin"
  password          = var.is_tofu_test ? random_password.password.result : var.instance_pw

  publicly_accessible = false
  storage_encrypted   = true

  iam_database_authentication_enabled = true
  enabled_cloudwatch_logs_exports     = ["error", "general", "slowquery"]

  deletion_protection       = var.db_deletion_protection
  skip_final_snapshot       = var.db_skip_final_snapshot
  final_snapshot_identifier = "db-snapshot-${local.timestamp_sanitized}"

  # snapshot_identifier = [insert snapshot to rebuild db from]

  vpc_security_group_ids = [aws_security_group.rds_secgrp.id]
  db_subnet_group_name   = aws_db_subnet_group.default.name

  backup_retention_period = 7
  backup_window           = "12:45-01:15"
  maintenance_window      = "sun:05:00-sun:06:00"

}

resource "mysql_database" "databases" {
  for_each = { for idx, combo in var.app_env_list : "${combo.app}-${combo.env}" => combo }
  name     = each.key
}

resource "mysql_user" "appusers" {
  for_each = {
    for idx, combo in var.app_env_list :
    "${combo.app}-${combo.env}" => {
      combo    = combo
      password = var.passwords[idx]
    }
  }
  user               = each.key
  plaintext_password = each.value.password
}

resource "mysql_grant" "appgrants" {
  for_each   = { for idx, combo in var.app_env_list : "${combo.app}-${combo.env}" => combo }
  user       = each.key
  host       = aws_db_instance.default.address
  database   = each.key
  privileges = ["ALL"]
}

###############################################################
# Resource to tofu test if databases were created             #
###############################################################

resource "null_resource" "check_databases" {
  for_each = {
    for idx, combo in var.app_env_list :
    "${combo.app}-${combo.env}" => {
      combo    = combo
      password = var.passwords[idx]
    }
  }

  provisioner "local-exec" {

    command = <<EOT

    # Check if the database exists and write the result to a temp file
    mysql -h ${aws_db_instance.default.address} -P 3306 -uadmin -p'${aws_db_instance.default.password}' -e "SHOW DATABASES LIKE \`${each.key}\`;" > /tmp/db_check_${each.key}.txt 
    EOT 
  }

  depends_on = [aws_db_instance.default]
}
