# Timestamps for name uniqueness to prevent apply collisions
locals {
  timestamp           = timestamp()
  timestamp_sanitized = replace(local.timestamp, "/[-| |T|Z|:]/", "")
}
