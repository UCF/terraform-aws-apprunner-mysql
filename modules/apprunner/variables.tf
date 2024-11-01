variable "applications" {
  type        = list(string)
  description = "A list of available applications"
  default     = ["announcements"]
}

variable "environments" {
  type        = list(string)
  description = "A list of available environments"
  default     = ["dev"]
}

variable "app_env_list" {
  type = list(object({
    app = string
    env = string
  }))
}

variable "ecr_repo_names" {
  type = list(string)
}

variable "region" {
  type = string
  default = "us-east-1"
}

variable "domain_name" {
  type = string
  default = "cm.ucf.edu"
}
