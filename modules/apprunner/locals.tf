locals {
  app_env_map = { for combo in var.app_env_list : "${combo.app}-${combo.env}" => combo }
}
