resource "aws_secretsmanager_secret" "db_credentials" {
  name = "rds-mysql"
}

data "aws_secretsmanager_secret_version" "db_credentials" {
  secret_id = "arn:aws:secretsmanager:us-east-1:654654512735:secret:rds-mysql-84SD5b"
}

locals {
  db_credentials = jsondecode(data.aws_secretsmanager_secret_version.db_credentials.secret_string)
}

resource "aws_secretsmanager_secret_version" "db_credentials_version" {
  secret_id = aws_secretsmanager_secret.db_credentials.id
  secret_string = jsonencode({
    username = var.db_username
    password = var.db_password
  })
}

