# Necessary for uniqueness of database snapshot names to prevent apply failure

locals {
  timestamp           = timestamp()
  timestamp_sanitized = replace(local.timestamp, "/[-| |T|Z|:]/", "")
  tofutestpw          = random_password.password.result
  db_password         = var.is_tofu_test ? local.tofutestpw : var.instance_pw
}
