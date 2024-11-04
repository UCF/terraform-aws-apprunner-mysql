provider "aws" {
  region = var.region
}

provider "mysql" {
  endpoint = aws_db_instance.default.address
  username = aws_db_instance.default.username
  password = aws_db_instance.default.password
}
