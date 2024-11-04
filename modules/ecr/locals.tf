locals {
  # Timestamps are used for image tag uniqueness to prevent apply failure
  timestamp           = timestamp()
  timestamp_sanitized = replace(local.timestamp, "/[-| |T|Z|:]/", "")
}
