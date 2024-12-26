terraform {
  source = "." 
}

include {
  path = find_in_parent_folders()
}

dependency "ecr" {
  config_path = "../ecr"
  mock_outputs_allowed_terraform_commands = ["init", "plan", "destroy"]
  mock_outputs = {
    ecr_repo_names = ["announcements-dev", "announcements-test", "template-dev", "template-test"]
  }
}

inputs = {
  ecr_repositories = dependency.ecr.outputs.ecr_repo_names
}

