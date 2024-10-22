data "aws_caller_identity" "current" {}

module "appenvlist" {
  source = "../appenvlist"
  
  applications = var.applications
  environments = var.environments
}

module "iam" {
  source = "../iam"
}

resource "aws_apprunner_service" "app_services" {
  for_each = { for combo in module.appenvlist.app_env_list : "${combo.app}-${combo.env}" => combo }

  service_name = "${each.value.app}-${each.value.env}-service"

  source_configuration {
    image_repository {
      image_configuration {
        port = var.is_tofu_test_environment ? "80" : "8000"
      }
      image_identifier      = var.is_tofu_test_environment ? "public.ecr.aws/aws-containers/hello-app-runner:latest" : "${data.aws_caller_identity.current.account_id}.dkr.ecr.us-east-1.amazonaws.com/${each.value.app}-${each.value.env}:latest"
      image_repository_type = var.is_tofu_test_environment ? "ECR_PUBLIC" : "ECR"
    }

    authentication_configuration {
      access_role_arn = module.iam.apprunner_access_role_arn
    }
  }

  auto_scaling_configuration_arn = aws_apprunner_auto_scaling_configuration_version.app_scaling.arn

  tags = {
    Environment = each.value.env
    Application = each.value.app
  }

  depends_on = [module.iam]
}

resource "aws_apprunner_auto_scaling_configuration_version" "app_scaling" {
  auto_scaling_configuration_name = "app-scaling-config"

  max_concurrency = 100
  max_size        = 3
  min_size        = 1
}
