####################################################################
# main.tf                                           		   #
####################################################################
# Creates necessary AWS infrastructure for an RDS MySQL instance.  #
####################################################################

####################################################################
# VPC   							   #
####################################################################

resource "aws_vpc" "main" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true
}

resource "aws_apprunner_vpc_connector" "app_vpc_connector" {
  vpc_connector_name = "app-vpc-connector"
  subnets            = [aws_subnet.main.id, aws_subnet.alternative.id]
  security_groups    = [aws_security_group.apprunner_sg.id]
}

resource "aws_flow_log" "vpc_flow_logs" {
  vpc_id               = aws_vpc.main.id
  log_destination      = aws_cloudwatch_log_group.vpc_flow_logs.arn
  log_destination_type = "cloud-watch-logs"
  traffic_type         = "ALL"
  iam_role_arn         = aws_iam_role.flow_logs_role.arn
}

resource "aws_iam_role" "flow_logs_role" {
  name = "vpc-flow-logs-role"

  assume_role_policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Principal" : {
          "Service" : "vpc-flow-logs.amazonaws.com"
        },
        "Action" : "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "flow_logs_policy_attachment" {
  role       = aws_iam_role.flow_logs_role.name
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchLogsFullAccess"
}

resource "aws_cloudwatch_log_group" "vpc_flow_logs" {
  name              = "/aws/vpc/flow-logs-${aws_vpc.main.id}"
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
  name       = "appfolio_subnet_group"
  subnet_ids = [aws_subnet.main.id, aws_subnet.alternative.id]
}

################################################################
# Security groups 					       #
################################################################                    

resource "aws_security_group" "rds_secgrp" {
  vpc_id = aws_vpc.main.id
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group_rule" "rds_secgrp_ingress" {
  type              = "ingress"
  from_port         = 3306
  to_port           = 3306
  protocol          = "tcp"
  source_security_group_id = aws_security_group.bastion_sg.id
  security_group_id = aws_security_group.rds_secgrp.id
}

data "external" "ip" {
  program = ["bash", "-c", "curl -s https://checkip.amazonaws.com | awk '{print \"{\\\"ip\\\": \\\"\" $1 \"\\\"}\"}'"]
}

resource "aws_security_group" "bastion_sg" {
  vpc_id = aws_vpc.main.id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group_rule" "bastion_ingress" {
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  cidr_blocks       = ["${data.external.ip.result["ip"]}/32"]
  security_group_id = aws_security_group.bastion_sg.id
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
# Route tables and associations                                 #
#################################################################

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }
}

resource "aws_route_table_association" "public" {
  route_table_id = aws_route_table.public.id

  subnet_id = aws_subnet.nat_subnet.id
}

resource "aws_route_table" "private" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat.id
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

