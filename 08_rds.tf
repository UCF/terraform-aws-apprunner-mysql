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

  db_subnet_group_name   = module.vpc.database_subnet_group
  vpc_security_group_ids = [aws_security_group.db_sg.id]
  publicly_accessible    = true

}
