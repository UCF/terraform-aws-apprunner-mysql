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
