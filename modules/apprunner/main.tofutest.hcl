variables {
  applications = ["announcements", "template"]
  environments = ["dev", "test"]
}

run "aws_apprunner_service_creation" {
  assert {
    # Check if the service name is correctly set for each app-environment combo
    condition = alltrue([for key, service in resource.aws_apprunner_service.app_services : service.service_name == "${service.tags.Application}-${service.tags.Environment}-service"])
    error_message = "AppRunner service name is incorrect."
  }

  assert {
    # Check if the image repository type is ECR
    condition = alltrue([for key, service in resource.aws_apprunner_service.app_services : service.source_configuration[0].image_repository[0].image_repository_type == "ECR"])
    error_message = "Image repository type is not set to ECR."
  }

  assert {
    # Check if the authentication configuration uses the correct role
    condition = alltrue([for key, service in resource.aws_apprunner_service.app_services : service.source_configuration[0].authentication_configuration[0].access_role_arn == "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/apprunner-access-role"])
    error_message = "AppRunner service does not have the correct access role ARN."
  }
}
