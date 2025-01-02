############################################################################
# main.tofutest.hcl                                                        #
############################################################################
# Tests for Vitess EKS Cluster                                             #
# ----------------------------                                             #
# Prerequisites:                                                           #
#   To run these tests, you must                                           #
#       - add "apply" to the mock_outputs_allowed_terraform_commands list  #
#            in the eks module's terragrunt.hcl file                       # 
#       - terragrunt apply the eks module (not tofu apply)                 #
#       - input the four vitess_cluster_* outputs into variables below     #
# ---------------------------                                              #
# Cleanup:                                                                 #
#   To clean up after testing, you must                                    #
#       -  add "destroy" to the mock_outputs_allowed_terraform_comands     #
#            list in the eks module's terragrunt.hcl                       #
#       -  replace the four vitess_cluster_* outputs with defaults         #
#       -  terragrunt destroy the eks modules  (not tofu destroy)          #
#       -  remove "apply" and "destroy" from the allowed commands list     #
############################################################################

variables {
  applications = ["announcements", "template"]
  environments = ["dev", "test"]
  app_env_list = [
    { app = "announcements", env = "dev" },
    { app = "announcements", env = "test" },
    { app = "template", env = "dev" },
    { app = "template", env = "test" },
  ]
  passwords        = ["anndev", "anntest", "tempdev", "temptest"]
  ecr_repositories = ["announcements-dev", "announcements-test", "template-dev", "template-test"]
  vitess_cluster_host = 
  vitess_cluster_token = 
  vitess_cluster_ca_certificate = 
}

#######################################################################
# Vitess Operator                                                     #
#######################################################################

run "vitess_operator_was_created" {
  assert {
    # Check that the pod creation result file exists and contains the expected output
    condition     = kubernetes_manifest.vitess_operator.manifest == yamldecode(file("vitess_config/operator.yaml")) && fileexists("/tmp/pod_check_result.txt")
    error_message = "Vitess operator creation verification failed."
  }
}

run "vitess_operator_manifests_exist" {
  assert {
    condition = [for manifest in kubernetes_manifest.vitess_operator.manifest : manifest == yamldecode(trimspace(local.vitess_operator_yaml_docs))]
    error_message = "At least one Vitess Operator manifest does not exist."
  }
}

#######################################################################
# Database Tests                                                      #
#######################################################################

#run "null_resource_runs" {
#  assert {
#    condition     = alltrue([for key, resource in resource.null_resource.create_databases : resource.id != ""])
#    error_message = "Database creation command failed."
#  }
#}
#
#
#run "check_database_creation" {
#  assert {
#    # Check that the database creation result file exists and contains the expected output
#    condition     = alltrue([for combo in var.app_env_list : fileexists("/tmp/db_check_${combo.app}_${combo.env}.txt") && length(fileset("/tmp", "db_check_${combo.app}_${combo.env}.txt")) > 0])
#    error_message = "Database creation verification failed for one or more environments."
#  }
#}
