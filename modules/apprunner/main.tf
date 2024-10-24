data "aws_caller_identity" "current" {}

module "ecr" {
  source = "../ecr"

  applications = var.applications
  environments = var.environments
}

module "iam" {
  source = "../iam"
}

resource "aws_apprunner_service" "app_services" {
  for_each = toset(module.ecr.ecr_repo_names)

  service_name = "${each.value}-service"

  source_configuration {
    image_repository {
      image_configuration {
        # Workaround for testing default nginx container at port 80 to guarantee AppRunner completes its setup
        port = var.is_tofu_test_environment ? "80" : "8000"
      }
      image_identifier      = "${data.aws_caller_identity.current.account_id}.dkr.ecr.us-east-1.amazonaws.com/${each.value}:latest"
      image_repository_type = "ECR"
    }

    authentication_configuration {
      access_role_arn = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/apprunner-access-role"
    }
  }

  auto_scaling_configuration_arn = aws_apprunner_auto_scaling_configuration_version.app_scaling.arn

  depends_on = [module.iam, module.ecr]
}

resource "aws_apprunner_auto_scaling_configuration_version" "app_scaling" {
  auto_scaling_configuration_name = "app-scaling-config"

  max_concurrency = 100
  max_size        = 3
  min_size        = 1
}
