locals {
  # Timestamps are used for database snapshot name uniqueness to prevent apply failure
  timestamp = timestamp()
  timestamp_sanitized = replace("${local.timestamp}", "/[-| |T|Z|:]/", "")
}
