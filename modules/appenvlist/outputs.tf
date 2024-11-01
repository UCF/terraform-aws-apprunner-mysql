output "app_env_list" {

  type = list(object({
    app = string
    env = string
  }))

  description = "A combined list of required applications and their environments"
  value       = local.app_env_list
}
