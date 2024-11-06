#######################
# main.tf             #
#######################

###########################################
# Current account data                    #
###########################################

data "aws_caller_identity" "current" {}

###########################################
# AppRunner services                      #
###########################################

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

  tags = {
    app = split("-", each.value)[0]
    env = split("-", each.value)[1]
  }
}

resource "aws_apprunner_auto_scaling_configuration_version" "app_scaling" {
  auto_scaling_configuration_name = "app-scaling-config"

  max_concurrency = 100
  max_size        = 3
  min_size        = 1
}

resource "aws_apprunner_custom_domain_association" "domains" {
  for_each = local.app_env_map

  domain_name = each.value.env == "prod" ? "${each.value.app}.${var.domain_name}" : "${each.value.app}-${each.value.env}.${var.domain_name}"
  service_arn = one(
    [for service in aws_apprunner_service.app_services : service.arn if service.tags["app"] == each.value.app && service.tags["env"] == each.value.env]
  )
}
