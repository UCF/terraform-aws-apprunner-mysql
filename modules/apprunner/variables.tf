variable "applications" {
  type        = list(string)
  description = "A list of applications to run"
}

variable "environments" {
  type        = list(string)
  description = "A list of environments to run applications in"
}

variable "is_tofu_test_environment" {
  type = bool
  default = false
}
