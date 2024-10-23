variable "applications" {
  type        = list(string)
  description = "A list of available applications"
}

variable "environments" {
  type        = list(string)
  description = "A list of available environments"
}

variable "is_tofu_test_environment" {
  type        = bool
  description = "Determines if Tofu Test environment is active"
  default     = false
}
