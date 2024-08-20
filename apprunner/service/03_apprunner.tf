resource "aws_apprunner_service" "app_services" {
  for_each = { for combo in local.app_env_list : "${combo.app}-${combo.env}" => combo }

  service_name = "${each.value.app}-${each.value.env}-service"

  source_configuration {
    image_repository {
      image_configuration {
        port = "8000"
      }
      image_identifier      = "654654512735.dkr.ecr.us-east-1.amazonaws.com/${each.value.app}-${each.value.env}:latest"
      image_repository_type = "ECR"
    }

    authentication_configuration {
      access_role_arn = var.access_role_arn
    }
  }

  instance_configuration {
    cpu    = "1024"
    memory = "2048"
  }

  auto_scaling_configuration_arn = aws_apprunner_auto_scaling_configuration_version.app_scaling.arn

  tags = {
    Environment = each.value.env
    Application = each.value.app
  }

}

resource "aws_apprunner_auto_scaling_configuration_version" "app_scaling" {
  auto_scaling_configuration_name = "app-scaling-config"

  max_concurrency = 100
  max_size        = 3
  min_size        = 1
}

