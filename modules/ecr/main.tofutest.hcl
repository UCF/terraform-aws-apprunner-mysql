variables {
  region       = "us-east-1"
  applications = ["announcements", "template"]
  environments = ["dev", "qa"]
}

run "test" {
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

run "override" {
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
