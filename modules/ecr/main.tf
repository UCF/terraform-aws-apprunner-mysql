terraform {
  required_version = ">=1.9"
}

provider "aws" {
  region = "us-east-1"
}


module "appenvlist" {
  source = "../appenvlist"

  applications = var.applications
  environments = var.environments
}

resource "aws_ecr_repository" "app_repos" {
  for_each = {for combo in module.appenvlist.app_env_list : "${combo.app}-${combo.env}" => combo }

  name = "${each.value.app}-${each.value.env}"
  force_delete = true
}
