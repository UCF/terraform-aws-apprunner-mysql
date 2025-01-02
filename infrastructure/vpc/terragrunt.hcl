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

inputs = {
  app_env_list = dependency.appenvlist.outputs.app_env_list
}
