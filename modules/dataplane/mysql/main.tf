####################################################################
# main.tf                                           		   #
####################################################################
# Creates necessary AWS infrastructure for an RDS MySQL instance.  #
####################################################################

###############################################################
# App DBs, users, and permission grants                       #
###############################################################


resource "mysql_database" "databases" {
  for_each = { for idx, combo in var.app_env_list : "${combo.app}-${combo.env}" => combo }

  name = each.key

}


resource "mysql_user" "appusers" {
  for_each = {
    for idx, combo in var.app_env_list :
    "${combo.app}-${combo.env}" => {
      combo    = combo
      password = var.app_db_passwords[idx]
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
  privileges = ["SELECT", "INSERT", "UPDATE", "DELETE", "CREATE", "DROP", "ALTER", "INDEX", "EXECUTE", "TRIGGER"]

}

