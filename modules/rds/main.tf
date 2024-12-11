####################################################################
# main.tf                                           		   #
####################################################################
# Creates necessary AWS infrastructure for an RDS MySQL instance.  #
####################################################################

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

  vpc_security_group_ids = [var.rds_secgrp_id]
  db_subnet_group_name   = var.db_sg_name

  backup_retention_period = 7
  backup_window           = "12:45-01:15"
  maintenance_window      = "sun:05:00-sun:06:00"

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
  subnet_id                   = var.subnet_id
  vpc_security_group_ids      = [var.bastion_sg_id]
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

