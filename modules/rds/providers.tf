provider "aws" {
  region = var.region
}

provider "mysql" {
  endpoint = aws_instance.bastion.public_ip
  username = "admin"
  password = var.is_tofu_test ? local.tofutestpw : var.instance_pw
}
