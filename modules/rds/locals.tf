# Necessary for uniqueness of database snapshot names to prevent apply failure

locals {
  timestamp           = timestamp()
  timestamp_sanitized = replace(local.timestamp, "/[-| |T|Z|:]/", "")
}
