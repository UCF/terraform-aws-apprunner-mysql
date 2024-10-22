variable "db_public_access" {
  type        = bool
  description = "Whether the db is open for public access or not"
  default     = true
}

variable "db_deletion_protection" {
  type        = bool
  description = "Whether the db has deletion protection"
  default     = false
}

variable "db_skip_final_snapshot" {
  type        = bool
  description = "Whether to skip the final database snapshot"
  default     = false
}

variable "applications" {
  type        = list(string)
  description = "A list of applications to run"
}

variable "environments" {
  type        = list(string)
  description = "A list of environments to run applications in"
}
