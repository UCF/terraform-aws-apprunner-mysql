variable "region" {
  type    = string
  default = "us-east-1"
}

variable "adminpw" {
  type = string
  default = "tofutestpw"
}

variable "app_env_list" {
  type = list(object({
    app = string
    env = string
  }))
  description = "The App-Env List imported from the appenvlist module"
  default = [
    { app = "announcements", env = "dev" },
    { app = "announcements", env = "test" },
    { app = "template", env = "dev" },
    { app = "template", env = "test" },
  ]
}

variable "ecr_repositories" {
  type = list(string)
  default = ["announcements-dev", "announcements-test", "template-dev", "template-test"]
}

variable "passwords" {
  type = list(string)
  default = ["tofutestanndev", "tofutestanntest", "tofutesttempdev", "tofutesttemtest"]
}
