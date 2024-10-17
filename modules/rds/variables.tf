variable "db_password" { 
	type = string
	sensitive = true
	description = "The password for the RDS instance"
}
