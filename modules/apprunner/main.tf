provider "aws" {
  region = var.region 
}

data "aws_caller_identity" "current" {}

resource "aws_apprunner_service" "app_services" {
  for_each = toset(var.ecr_repo_names)

  service_name = "${each.value}-service"

  source_configuration {
    image_repository {
      image_configuration {
        port = "80"
      }
      image_identifier      = "${data.aws_caller_identity.current.account_id}.dkr.ecr.us-east-1.amazonaws.com/${each.value}:latest"
      image_repository_type = "ECR"
    }

    authentication_configuration {
      access_role_arn = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/apprunner-access-role"
    }
  }

  auto_scaling_configuration_arn = aws_apprunner_auto_scaling_configuration_version.app_scaling.arn

}

resource "aws_apprunner_auto_scaling_configuration_version" "app_scaling" {
  auto_scaling_configuration_name = "app-scaling-config"

  max_concurrency = 100
  max_size        = 3
  min_size        = 1
}

locals {
  service_arn_map = zipmap(var.ecr_repo_names, aws_apprunner_service.app_services[*].arn)
}

resource "aws_apprunner_custom_domain_association" "domains" {
  for_each = toset(var.ecr_repo_names)

  domain_name = "${each.value}.cm.ucf.edu"
  service_arn = local.service_arn_map[each.value]
}






