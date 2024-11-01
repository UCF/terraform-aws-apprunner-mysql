variable "region" {
  type        = string
  description = "AWS Region name"
  default     = "us-east-1"
}

variable "app_env_list" {
  type = list(object({
           app = string
           env = string
         }))
}
