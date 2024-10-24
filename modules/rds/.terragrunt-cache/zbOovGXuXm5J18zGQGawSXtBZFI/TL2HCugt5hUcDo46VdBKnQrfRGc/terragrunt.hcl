terraform {
  source = "."  # Path to the actual RDS Terraform module
}

dependency "appenvlist" {
  config_path = "../appenvlist"
}

inputs = {
  app_env_list = dependency.appenvlist.outputs.app_env_list
}
