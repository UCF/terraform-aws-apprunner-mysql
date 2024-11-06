# RDS and databases setup using App-Env List combination

This module uses the appenvlist module in order to spin up an RDS instance and its dependencies along with a number of databases based on the application names and environment names fed to the first appenvlist module.


<--BEGIN TF DOCS-->
## Requirements

The following requirements are needed by this module:

- <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) (1.8.3)

- <a name="requirement_aws"></a> [aws](#requirement\_aws) (5.74.0)

- <a name="requirement_mysql"></a> [mysql](#requirement\_mysql) (3.0.65)

- <a name="requirement_null"></a> [null](#requirement\_null) (3.2.3)

- <a name="requirement_random"></a> [random](#requirement\_random) (3.6.3)

## Providers

The following providers are used by this module:

- <a name="provider_aws"></a> [aws](#provider\_aws) (5.73.0)

- <a name="provider_mysql"></a> [mysql](#provider\_mysql) (1.9.0)

- <a name="provider_null"></a> [null](#provider\_null) (3.2.3)

- <a name="provider_random"></a> [random](#provider\_random) (3.6.3)

## Modules

No modules.

## Resources

The following resources are used by this module:

- [aws_db_instance.default](https://registry.terraform.io/providers/hashicorp/aws/5.74.0/docs/resources/db_instance) (resource)
- [aws_db_subnet_group.default](https://registry.terraform.io/providers/hashicorp/aws/5.74.0/docs/resources/db_subnet_group) (resource)
- [aws_internet_gateway.main](https://registry.terraform.io/providers/hashicorp/aws/5.74.0/docs/resources/internet_gateway) (resource)
- [aws_route_table.public](https://registry.terraform.io/providers/hashicorp/aws/5.74.0/docs/resources/route_table) (resource)
- [aws_route_table_association.alt_subnet_association](https://registry.terraform.io/providers/hashicorp/aws/5.74.0/docs/resources/route_table_association) (resource)
- [aws_route_table_association.main_subnet_association](https://registry.terraform.io/providers/hashicorp/aws/5.74.0/docs/resources/route_table_association) (resource)
- [aws_security_group.rds_secgrp](https://registry.terraform.io/providers/hashicorp/aws/5.74.0/docs/resources/security_group) (resource)
- [aws_subnet.alternative](https://registry.terraform.io/providers/hashicorp/aws/5.74.0/docs/resources/subnet) (resource)
- [aws_subnet.main](https://registry.terraform.io/providers/hashicorp/aws/5.74.0/docs/resources/subnet) (resource)
- [aws_vpc.main](https://registry.terraform.io/providers/hashicorp/aws/5.74.0/docs/resources/vpc) (resource)
- [mysql_database.databases](https://registry.terraform.io/providers/hashicorp/mysql/3.0.65/docs/resources/database) (resource)
- [mysql_grant.appgrants](https://registry.terraform.io/providers/hashicorp/mysql/3.0.65/docs/resources/grant) (resource)
- [mysql_user.appusers](https://registry.terraform.io/providers/hashicorp/mysql/3.0.65/docs/resources/user) (resource)
- [null_resource.check_databases](https://registry.terraform.io/providers/hashicorp/null/3.2.3/docs/resources/resource) (resource)
- [random_password.password](https://registry.terraform.io/providers/hashicorp/random/3.6.3/docs/resources/password) (resource)

## Required Inputs

The following input variables are required:

### <a name="input_app_env_list"></a> [app\_env\_list](#input\_app\_env\_list)

Description: n/a

Type:

```hcl
list(object({
    app = string
    env = string
  }))
```

### <a name="input_instance_pw"></a> [instance\_pw](#input\_instance\_pw)

Description: The main password for the database instance

Type: `string`

### <a name="input_passwords"></a> [passwords](#input\_passwords)

Description: The passwords for each database

Type: `list(string)`

## Optional Inputs

The following input variables are optional (have default values):

### <a name="input_db_deletion_protection"></a> [db\_deletion\_protection](#input\_db\_deletion\_protection)

Description: Whether the db has deletion protection

Type: `bool`

Default: `false`

### <a name="input_db_public_access"></a> [db\_public\_access](#input\_db\_public\_access)

Description: Whether the db is open for public access or not

Type: `bool`

Default: `true`

### <a name="input_db_skip_final_snapshot"></a> [db\_skip\_final\_snapshot](#input\_db\_skip\_final\_snapshot)

Description: Whether to skip the final database snapshot

Type: `bool`

Default: `false`

### <a name="input_is_tofu_test"></a> [is\_tofu\_test](#input\_is\_tofu\_test)

Description: n/a

Type: `bool`

Default: `false`

### <a name="input_region"></a> [region](#input\_region)

Description: n/a

Type: `string`

Default: `"us-east-1"`

## Outputs

The following outputs are exported:

### <a name="output_rds_endpoint"></a> [rds\_endpoint](#output\_rds\_endpoint)

Description: n/a
<--END TF DOCS-->
