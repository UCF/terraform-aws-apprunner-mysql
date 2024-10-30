variable "applications" {
  type        = list(string)
  description = "A list of applications to be hosted"
  default     = ["announcements"]

  validation {
    condition     = alltrue([for app in var.applications : length(app) < 27])
    error_message = "The combined length of applications and environments must be less than 32 characters. Applications names must be less than 27 characters."
  }
}

variable "environments" {
  type        = list(string)
  description = "A list of environments required for each application"
  default     = ["dev"]

  validation {
    condition     = alltrue([for env in var.environments : length(env) < 5])
    error_message = "The combined length of application-enviornment name combinations must be less than 32 characters. Environment names must be less than 5 characters."
  }
}
