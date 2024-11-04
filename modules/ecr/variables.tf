variable "app_env_list" {
  type = list(object({
    app = string
    env = string
  }))
}

variable "should_force_delete" {
  type        = bool
  description = "Determines if ECR repositories should be force-deleted on teardown. Should be false for production"
  default     = true
}
