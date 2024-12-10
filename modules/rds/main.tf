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
  name       = "default-subnet-group"
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
  cidr_blocks       = [aws_subnet.main.cidr_block, aws_subnet.alternative.cidr_block]
  security_group_id = aws_security_group.bastion_sg.id
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

################################################################
# Random password for tofu test db                             #
################################################################

resource "random_password" "password" {
  length  = 15
  special = false
}

###############################################################
# RDS instance, app DBs, users, and permission grants         #
###############################################################

resource "aws_db_instance" "default" {
  identifier        = "cm-appfolio-db"
  allocated_storage = 20
  engine            = "mysql"
  engine_version    = "8.0.32"
  instance_class    = "db.t3.micro"
  username          = "admin"
  password          = var.is_tofu_test ? local.tofutestpw : var.instance_pw

  publicly_accessible = false
  storage_encrypted   = true

  iam_database_authentication_enabled = true
  enabled_cloudwatch_logs_exports     = ["error", "general", "slowquery"]

  deletion_protection       = var.db_deletion_protection
  skip_final_snapshot       = var.db_skip_final_snapshot
  final_snapshot_identifier = "final-db-snapshot-cm-appfolio-db"

  # snapshot_identifier = [insert snapshot to rebuild db from]

  vpc_security_group_ids = [aws_security_group.rds_secgrp.id]
  db_subnet_group_name   = aws_db_subnet_group.default.name

  backup_retention_period = 7
  backup_window           = "12:45-01:15"
  maintenance_window      = "sun:05:00-sun:06:00"

}

resource "mysql_database" "databases" {
  for_each = { for idx, combo in var.app_env_list : "${combo.app}-${combo.env}" => combo }

  name = each.key

  depends_on = [null_resource.mysql_perms]
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

  depends_on = [mysql_database.databases]
}

resource "mysql_grant" "appgrants" {
  for_each = { for idx, combo in var.app_env_list : "${combo.app}-${combo.env}" => combo }

  user       = each.key
  database   = each.key
  privileges = ["ALL"]

  depends_on = [mysql_user.appusers]
}


################################################################################
# Bastion Host                                                                 #
################################################################################

resource "aws_iam_role" "session_manager_role" {
  name = "bastion-session-manager-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "ec2.amazonaws.com"
      }
    }]
  })
}

resource "aws_iam_role_policy_attachment" "session_manager_attachment" {
  role       = aws_iam_role.session_manager_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"

  depends_on = [aws_iam_role.session_manager_role]
}

data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["amazon"]
  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd-gp3/ubuntu-noble-24.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }
} 

resource "aws_instance" "bastion" {
  ami                         = data.aws_ami.ubuntu.id
  instance_type               = "t3.micro"
  subnet_id                   = aws_subnet.nat_subnet.id
  vpc_security_group_ids      = [aws_security_group.bastion_sg.id]
  iam_instance_profile        = aws_iam_instance_profile.session_manager_profile.id

  tags = {
    Name = "BastionHost"
  }
}

resource "aws_iam_instance_profile" "session_manager_profile" {
  name = "session-manager-profile"
  role = aws_iam_role.session_manager_role.name

  depends_on = [aws_iam_role.session_manager_role]
}

####################################################################
# SSH Tunnel Automation for MySQL Provider                         #
####################################################################

resource "null_resource" "mysql_perms" {
  triggers = {
    db_id = aws_db_instance.default.id
  }

  provisioner "local-exec" {
    command = <<EOT
      nohup aws ssm start-session \
        --target ${aws_instance.bastion.id} \
        --document-name AWS-StartPortForwardingSessionToRemoteHost \
        --parameters '{"host":["${aws_db_instance.default.address}"],"portNumber":["3306"], "localPortNumber":["3307"]}' \
        > /tmp/ssm-tunnel.log 2>&1 &
    EOT
  }

  provisioner "local-exec" {
    command = <<EOT
      mysql -h 127.0.0.1 --protocol=tcp -P 3307 -u admin -p"${local.db_password}" -e "
      GRANT ROLE_ADMIN ON *.* TO 'admin'@'%';
      FLUSH PRIVILEGES;"
    EOT
  }

  depends_on = [aws_db_instance.default, aws_instance.bastion]
}

resource "null_resource" "cleanup" {

  triggers = {
    null_resource_id = null_resource.mysql_perms.id
  }

  provisioner "local-exec" {
    command = "pkill -f session-manager-plugin"
  }

  # Can't do this because we have the state locked.
  # provisioner "local-exec" {
  #   command = "tofu destroy -target=aws_instance.bastion -target=aws_security_group.bastion_sg -target=aws_iam_role.session_manager_role -target=aws_iam_instance_profile.session_manager_profile -target=aws_iam_role_policy_attachment.session_manager_attachment -auto-approve"
  # }

  depends_on = [ mysql_grant.appgrants ]
}
