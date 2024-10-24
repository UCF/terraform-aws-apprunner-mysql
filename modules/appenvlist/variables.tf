variable "applications" {
  type        = list(string)
  description = "A list of applications to be hosted"
  default     = ["announcements"]
}

variable "environments" {
  type        = list(string)
  description = "A list of environments required for each application"
  default     = ["dev"]
}
