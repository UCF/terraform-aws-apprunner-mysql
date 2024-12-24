variables {
  region = "us-east-1"
  app_env_list = [{ app = "announcements", env = "dev" },
    { app = "announcements", env = "test" },
    { app = "template", env = "dev" },
    { app = "template", env = "test" },
  ]
}

# A default image is added to ensure the AppRunner tests and spin-up work
run "check_default_image_pushed_to_ecr" {

  assert {
    # Ensure all ECR repositories exist
    condition     = alltrue([for repo_key in keys(null_resource.check_ecr_images) : length(fileset("/tmp", "ecr_image_check_${repo_key}.json")) > 0])
    error_message = "An ECR repository does not exist"
  }
}

run "test5by3" {
  variables {
    region       = "us-east-1"
    applications = ["announcements", "template", "knightsherald", "events", "marquee"]
    environments = ["dev", "test", "prod"]
  }


  assert {
    # Verify the null_resource pushes image successfully
    condition     = alltrue([for repo_key in keys(null_resource.check_ecr_images) : null_resource.check_ecr_images[repo_key].id != ""])
    error_message = "The container image was not pushed to ECR successfully"
  }
}

