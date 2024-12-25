provider "aws" {
  region = var.region
}

provider "mysql" {
  host = "${data.aws_ecs_task.vitess_test.network_interface[0].private_ip}"
  username = "admin"
  password = var.adminpw
  port = 15999
}
