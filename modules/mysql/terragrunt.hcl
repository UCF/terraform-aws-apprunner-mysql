terraform {
  source = "." 
}

include {
  path = find_in_parent_folders()
}

dependency "appenvlist" {
  config_path = "../appenvlist"
  mock_outputs_allowed_terraform_commands = ["init", "plan", "destroy"]
  mock_outputs = {
    app_env_list = [
      { app = "announcements", env = "dev" },
      { app = "announcements", env = "test" },
      { app = "template", env = "dev" },
      { app = "template", env = "test" },
    ]
  }
}

dependency "rds" {
  config_path = "../rds"
  mock_outputs_allowed_terraform_commands = ["init", "plan", "destroy"]
  mock_outputs = {
    bastion_instance_id = "123"
    rds_endpoint = "123"
  }
}

inputs = {
  app_env_list = dependency.appenvlist.outputs.app_env_list
  bastion_instance_id = dependency.rds.outputs.bastion_instance_id
  rds_endpoint = dependency.rds.outputs.rds_endpoint
}
