terraform {
  required_version = ">=1.8.3"
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
