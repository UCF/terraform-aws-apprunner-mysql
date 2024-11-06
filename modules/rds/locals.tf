locals {
  timestamp           = timestamp()
  timestamp_sanitized = replace(local.timestamp, "/[-| |T|Z|:]/", "")
}
