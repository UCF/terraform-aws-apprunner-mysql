variable "applications" {
  type    = list(string)
  default = ["announcements"]
}

variable "environments" {
  type    = list(string)
  default = ["dev", "qa", "prod"]
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
