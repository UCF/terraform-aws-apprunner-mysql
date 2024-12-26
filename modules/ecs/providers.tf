provider "aws" {
  region = var.region
}

provider "mysql" {
  endpoint = "${data.aws_network_interface.task_eni.private_ip}:15999" 
  username = "admin"
  password = var.adminpw
}
