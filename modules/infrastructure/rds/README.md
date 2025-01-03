# RDS and databases setup using App-Env List combination

This module uses the appenvlist module in order to spin up an RDS instance and its dependencies along with a number of databases based on the application names and environment names fed to the first appenvlist module.


## Requirements

No requirements.

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | 5.72.1 |
| <a name="provider_null"></a> [null](#provider\_null) | 3.2.3 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_appenvlist"></a> [appenvlist](#module\_appenvlist) | ../appenvlist | n/a |

## Resources

| Name | Type |
|------|------|
| [aws_db_instance.default](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/db_instance) | resource |
| [aws_db_subnet_group.default](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/db_subnet_group) | resource |
| [aws_internet_gateway.main](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/internet_gateway) | resource |
| [aws_route_table.public](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table) | resource |
| [aws_route_table_association.alt_subnet_association](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table_association) | resource |
| [aws_route_table_association.main_subnet_association](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table_association) | resource |
| [aws_security_group.rds_secgrp](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |
| [aws_subnet.alternative](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/subnet) | resource |
| [aws_subnet.main](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/subnet) | resource |
| [aws_vpc.main](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc) | resource |
| [null_resource.create_databases](https://registry.terraform.io/providers/hashicorp/null/latest/docs/resources/resource) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_applications"></a> [applications](#input\_applications) | A list of applications to run | `list(string)` | n/a | yes |
| <a name="input_db_deletion_protection"></a> [db\_deletion\_protection](#input\_db\_deletion\_protection) | Whether the db has deletion protection | `bool` | `false` | no |
| <a name="input_db_password"></a> [db\_password](#input\_db\_password) | The password for the RDS instance | `string` | n/a | yes |
| <a name="input_db_public_access"></a> [db\_public\_access](#input\_db\_public\_access) | Whether the db is open for public access or not | `bool` | `true` | no |
| <a name="input_db_skip_final_snapshot"></a> [db\_skip\_final\_snapshot](#input\_db\_skip\_final\_snapshot) | Whether to skip the final database snapshot | `bool` | `false` | no |
| <a name="input_environments"></a> [environments](#input\_environments) | A list of environments to run applications in | `list(string)` | n/a | yes |


## Outputs

| Name | Description |
|------|-------------|
| <a name="output_rds_endpoint"></a> [rds\_endpoint](#output\_rds\_endpoint) | n/a |
