provider "aws" {
  region = var.region
}

locals {
  app_env_combinations = [
    for app in var.applications : [
      for env in var.environments : {
        app = app
        env = env
      }
    ]
  ]

  app_env_list = flatten(local.app_env_combinations)
}
