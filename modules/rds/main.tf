###############################################
# main.tf                                     #
###############################################

###############################################
# VPC                                         #
###############################################

resource "aws_vpc" "main" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true
}

##############################################
# Subnets and subnet group                   #
##############################################

resource "aws_subnet" "main" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "us-east-1c"
  map_public_ip_on_launch = true
}

resource "aws_subnet" "alternative" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.2.0/24"
  availability_zone       = "us-east-1b"
  map_public_ip_on_launch = true
}

resource "aws_db_subnet_group" "default" {
  name       = "default-subnet-group"
  subnet_ids = [aws_subnet.main.id, aws_subnet.alternative.id]
}

######################################################
# Security group                                     #
######################################################

resource "aws_security_group" "rds_secgrp" {
  vpc_id = aws_vpc.main.id

  ingress {
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] #Replace with more secure range
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

##############################################################
# Internet gateway                                           #
##############################################################

resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id
}

#############################################################
# Route table and associations                              #
#############################################################

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }
}

resource "aws_route_table_association" "main_subnet_association" {
  subnet_id      = aws_subnet.main.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "alt_subnet_association" {
  subnet_id      = aws_subnet.alternative.id
  route_table_id = aws_route_table.public.id
}

###########################################################
# Random password for tofu test                           #
###########################################################

resource "random_password" "password" {
  length           = 16
  special          = true
  override_special = "#&*=+:?"
}

##########################################################
# RDS instance                                           #
##########################################################

resource "aws_db_instance" "default" {
  identifier        = "cm-appfolio-db"
  allocated_storage = 20
  engine            = "mysql"
  engine_version    = "8.0"
  instance_class    = "db.t3.micro"
  username          = "admin"
  password          = var.is_tofu_test ? random_password.password.result : var.instance_pw

  publicly_accessible = var.db_public_access

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
