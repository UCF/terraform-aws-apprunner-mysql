terraform {
  source = "."
}

include {
  path = find_in_parent_folders()
}

dependency "appenvlist" {
  config_path = "../appenvlist"
}

inputs = {
  app_env_list = dependency.appenvlist.outputs.app_env_list
}
