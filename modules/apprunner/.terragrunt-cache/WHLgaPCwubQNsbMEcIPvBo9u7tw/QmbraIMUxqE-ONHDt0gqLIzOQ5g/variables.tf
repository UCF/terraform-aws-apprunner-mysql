variable "applications" {
  type        = list(string)
  description = "A list of available applications"
  default = ["announcements"]
}

variable "environments" {
  type        = list(string)
  description = "A list of available environments"
  default = ["dev"]
}

variable "is_tofu_test_environment" {
  type        = bool
  description = "Determines if Tofu Test environment is active"
  default     = false
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
