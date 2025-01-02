##############################################################################
# locals.tf                                                                  #
##############################################################################
#                                                                            #
# This file contains the main logic of this module, which is to take the     #
# list of required applications and environments and compress them into      #
# a list of objects for use by other modules                                 #
#									     #
##############################################################################

locals {
  app_env_combinations = [
    for app in var.applications : [
      for env in var.environments : {
        app = app
        env = env
      }
    ]
  ]

  app_env_list = flatten(local.app_env_combinations)
}
