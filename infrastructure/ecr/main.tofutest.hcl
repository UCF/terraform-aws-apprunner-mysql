variables {
  region = "us-east-1"
  app_env_list = [{ app = "announcements", env = "dev" },
    { app = "announcements", env = "test" },
    { app = "template", env = "dev" },
    { app = "template", env = "test" },
  ]
}

run "test2by2" {
  variables {
    region       = "us-east-1"
    applications = ["announcements", "template"]
    environments = ["dev", "test"]
  }

  assert {
    condition = output.ecr_repo_names == [
      "announcements-dev",
      "announcements-test",
      "template-dev",
      "template-test",
    ]

    error_message = "Incorrect repository list."

  }
}

run "test5by3" {
  variables {
    region       = "us-east-1"
    applications = ["announcements", "template", "knightsherald", "events", "marquee"]
    environments = ["dev", "test", "prod"]
  }

  assert {
    condition = alltrue([
      for o in output.ecr_repo_names : contains([
        "announcements-dev",
        "announcements-prod",
        "announcements-test",
        "template-dev",
        "template-prod",
        "template-test",
        "knightsherald-dev",
        "knightsherald-prod",
        "knightsherald-test",
        "events-dev",
        "events-prod",
        "events-test",
        "marquee-dev",
        "marquee-prod",
        "marquee-test",
      ], o)
    ])

    error_message = "Incorrect ECR repository names."
  }
}

# A default image is added to ensure the AppRunner tests and spin-up work
run "check_default_image_pushed_to_ecr" {

  assert {
    # Verify the null_resource pushes image successfully
    condition     = alltrue([for repo_key in keys(null_resource.check_ecr_images) : null_resource.check_ecr_images[repo_key].id != ""])
    error_message = "The container image was not pushed to ECR successfully"
  }

  assert {
    # Ensure all ECR repositories exist
    condition     = alltrue([for repo_key in keys(null_resource.check_ecr_images) : length(fileset("/tmp", "ecr_image_check_${repo_key}.json")) > 0])
    error_message = "An ECR repository does not exist"
  }
}
