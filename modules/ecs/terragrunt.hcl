terraform {
  source = "." 
}

include {
  path = find_in_parent_folders()
}

dependency "iam" {
  config_path = "../iam"
}

dependency "vpc" {
  config_path = "../vpc"
}

inputs = {
  apprunner_arn = dependency.iam.outputs.apprunner_arn
  github_access_role_arn = dependency.iam.outputs.github_access_role_arn
  oidc_arn = dependency.iam.outputs.oidc_arn 
}

