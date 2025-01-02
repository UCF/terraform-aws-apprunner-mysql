provider "aws" {
  region = var.region
}

provider "mysql" {
  endpoint = "127.0.0.1:3306"
  username = "admin"
  password = var.is_tofu_test ? local.tofutestpw : var.instance_pw
}
