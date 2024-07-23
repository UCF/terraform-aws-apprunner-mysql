resource "aws_db_instance" "mysql" {

  engine            = "mysql"
  engine_version    = "8.0"
  instance_class    = "db.t3.micro"
  allocated_storage = 20
  storage_type      = "gp2"
  db_name           = var.db_name
  username          = var.db_username
  password          = var.db_password
  port              = "3306"

  db_subnet_group_name   = aws_db_subnet_group.mysql-group.name
  vpc_security_group_ids = [aws_security_group.db_sg.id]
  publicly_accessible    = true

  skip_final_snapshot = true
}

resource "aws_db_subnet_group" "mysql-group" {
  name       = "db_subnet_group_${local.timestamp}"
  subnet_ids = module.vpc.public_subnets
}


