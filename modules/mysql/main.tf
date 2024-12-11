####################################################################
# main.tf                                           		   #
####################################################################
# Creates necessary AWS infrastructure for an RDS MySQL instance.  #
####################################################################


resource "null_resource" "ssm_tunnel" {
  provisioner "local-exec" {
    command = <<EOT
      aws ssm start-session \
        --target ${var.bastion_instance_id} \
        --document-name AWS-StartPortForwardingSession \
        --region us-east-1
        --parameters '{"portNumber":["3306"], "localPortNumber":["3306"]}' &
      EOT
      }

    triggers = {
      bastion_instance_id = var.bastion_instance_id
      rds_endpoint = var.rds_endpoint
    }
}


###############################################################
# App DBs, users, and permission grants                       #
###############################################################

resource "mysql_grant" "admingrant" {
  user = "admin"
  database = "*"
  privileges = ["ALL"]

  depends_on = [null_resource.ssm_tunnel]
}

resource "mysql_database" "databases" {
  for_each = { for idx, combo in var.app_env_list : "${combo.app}-${combo.env}" => combo }

  name = each.key

  depends_on = [mysql_grant.admingrant]
}


resource "mysql_user" "appusers" {
  for_each = {
    for idx, combo in var.app_env_list :
    "${combo.app}-${combo.env}" => {
      combo    = combo
      password = var.passwords[idx]
    }
  }
  user               = each.key
  plaintext_password = each.value.password

  depends_on = [mysql_database.databases]
}

resource "mysql_grant" "appgrants" {
  for_each = { for idx, combo in var.app_env_list : "${combo.app}-${combo.env}" => combo }

  user       = each.key
  database   = each.key
  privileges = ["ALL"]

  depends_on = [mysql_grant.admingrant]
}

