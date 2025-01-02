variable "region" {
  type    = string
  default = "us-east-1"
}

variable "is_tofu_test" {
  type    = bool
  default = false
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

variable "app_env_list" {
  type = list(object({
    app = string
    env = string
  }))
  description = "Inputted list of app-env combinations."
}

variable "instance_pw" {
  type        = string
  description = "The main password for the database instance"
}

variable "passwords" {
  type        = list(string)
  description = "The passwords for each database"
}
