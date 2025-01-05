provider "aws" {
  region = var.region
}

provider "mysql" {
  endpoint = "${var.rds_endpoint}"
  username = "admin"
  password = var.instance_pw
}
