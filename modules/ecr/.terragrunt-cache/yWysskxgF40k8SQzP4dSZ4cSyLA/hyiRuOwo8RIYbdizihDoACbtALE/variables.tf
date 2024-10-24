variable "region" {
  type        = string
  description = "AWS Region name"
  default     = "us-east-1"
}

variable "applications" {
  type        = list(string)
  description = "List of application names"
}

variable "environments" {
  type        = list(string)
  description = "List of application environments"
}

variable "app_env_list" {
  type = list(object({
           app = string
           env = string
         }))
}
