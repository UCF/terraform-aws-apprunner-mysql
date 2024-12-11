provider "aws" {
  region = var.region
}

provider "mysql" {
  endpoint = aws_db_instance.default.endpoint
  username = "admin"
  password = var.is_tofu_test ? local.tofutestpw : var.instance_pw
}
