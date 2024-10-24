terraform {
  source = "."  
}

dependency "appenvlist" {
  config_path = "../appenvlist"
}

dependency "ecr" {
  config_path = "../ecr"
}

dependency "iam" {
  config_path = "../iam"
  skip_outputs = true
}

inputs = {
  ecr_repo_names = dependency.ecr.outputs.ecr_repo_names
  app_env_list = dependency.appenvlist.outputs.app_env_list
}
