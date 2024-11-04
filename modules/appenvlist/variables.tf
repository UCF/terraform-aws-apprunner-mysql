#################################################################
# variables.tf                                                  #
#################################################################
# This file contains the definitions of the input variables     #
# needed to run this module. Descriptions are outputted to the  #
# user if the variables have not been provided to the module.   #
#################################################################

variable "applications" {
  type        = list(string)
  description = "A list of applications to be hosted. Each application name must be less than 27 characters to comply with the MySQL database name length constraint."

# This default is optional and remains to serve as a syntax example
# default     = ["announcements", "template"]

  validation {
    condition     = alltrue([for app in var.applications : length(app) < 27])
    error_message = "The combined length of applications and environments must be less than 32 characters to comply with the MySQL database name length restriction. Applications names must be less than 27 characters."
  }
}

variable "environments" {
  type        = list(string)
  description = "A list of environments required for each application. Each environment name must be less than 5 characters to comply with the MySQL database name length constraint."

# This default is optional and remains to serve as a syntax example
# default     = ["dev", "test"]

  validation {
    condition     = alltrue([for env in var.environments : length(env) < 5])
    error_message = "The combined length of application-enviornment name combinations must be less than 32 characters to comply with the MySQL database name length restriction. Environment names must be less than 5 characters."
  }
}
