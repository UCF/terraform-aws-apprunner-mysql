run "test2by2" {
  variables {
    region       = "us-east-1"
    applications = ["announcements", "template"]
    environments = ["dev", "qa"]
  }

  assert {
    condition = output.ecr_repo_names == [
      "announcements-dev",
      "announcements-qa",
      "template-dev",
      "template-qa",
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
  condition = resource.null_resource.push_default_image.id != ""
  error_message = "The container image was not pushed to ECR successfully"
  }

  assert {
  # Ensure ECR reposiory exists
  condition = resource.aws_ecr_repository.repositories.repository_url != ""
  error_message = "ECR repository does not exist"
  }

  assert {
  # Use aws_ecr_lifecyle_policy to check image exists
  condition = length(resource.aws_ecr_repository.repositories.image_scan_findings) > 0
  error_message = "No images found in ECR repository"
  }
}
