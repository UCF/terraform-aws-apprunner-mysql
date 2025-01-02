###########################################################################
# main.tf                                                   		          #
###########################################################################
# Creates necessary AWS infrastructure for a Vitess ECS cluster           #
###########################################################################

###########################################################################
# Vitess                                                                  #
###########################################################################

resource "null_resource" "wait_for_eks" {
  provisioner "local-exec" {
    command = <<EOT
      TIMEOUT=600
      INTERVAL=10
      ELAPSED=0

      while [ $ELAPSED -lt $TIMEOUT ]; do
        STATUS=$(aws eks describe-cluster --name vitess-cluster --query "cluster.status" --output text)
        if [ "$STATUS" == "ACTIVE" ]; then
          echo "EKS cluster is active."
          exit 0
        fi
        sleep $INTERVAL
        ELAPSED=$((ELAPSED + INTERVAL))
      done

      echo "EKS cluster did not become active in time."
      exit 1
    EOT
  }
}

resource "kubernetes_manifest" "vitess_operator" {
  for_each = local.vitess_operator_yaml_docs
  manifest = yamldecode(trimspace(each.value))
  depends_on = [null_resource.wait_for_eks]
}

resource "null_resource" "check_vitess_operator_pod_exists" {
  depends_on = [kubernetes_manifest.vitess_operator]

  provisioner "local-exec" {
    command = <<EOT
      TIMEOUT=300
      INTERVAL=5
      ELAPSED=0

      while [ $ELAPSED -lt $TIMEOUT ]; do
        POD=$(kubectl get pods --no-headers)
        if [-n "$PODS"]; then
          echo "Pod exists." > /tmp/pod_check_result.txt
          exit 0
        fi
        sleep $INTERVAL
        ELAPSED=$((ELAPSED + INTERVAL))
      done
      exit 1
    EOT
  }
}

###########################################################################
# Vitess Databases and Users                                             #
###########################################################################

#resource "mysql_database" "databases" {
#  for_each = { for idx, combo in var.app_env_list : "${combo.app}-${combo.env}" => combo }
#  name     = each.key
#}
#
#resource "mysql_user" "appusers" {
#  for_each = {
#    for idx, combo in var.app_env_list :
#    "${combo.app}-${combo.env}" => {
#      combo    = combo
#      password = var.passwords[idx]
#    }
#  }
#  user               = each.key
#  plaintext_password = each.value.password
#  host               = "%"
#
#  depends_on = [mysql_database.databases]
#}
#
#resource "mysql_grant" "appgrants" {
#  for_each   = { for idx, combo in var.app_env_list : "${combo.app}-${combo.env}" => combo }
#  user       = each.key
#  host       = "%"
#  database   = each.key
#  privileges = ["ALL"]
#
#  depends_on = [mysql_user.appusers]
#}
#
############################################################################
## Database Verification                                                   #
############################################################################
#
#resource "null_resource" "check_databases" {
#  for_each = {
#    for idx, combo in var.app_env_list :
#    "${combo.app}-${combo.env}" => {
#      combo    = combo
#      password = var.passwords[idx]
#    }
#  }
#
#  provisioner "local-exec" {
#    command = <<EOT
#      # Check if the database exists and write the result to a temp file
#      vtctlclient GetSchema -tables ${each.key} ${aws_eks_cluster.vitess_cluster.endpoint}:15999 > /tmp/db_check_${each.key}.txt
#    EOT
#  }
#  depends_on = [mysql_grant.appgrants]
#}

