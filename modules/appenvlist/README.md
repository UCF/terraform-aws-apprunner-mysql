# AWS Application-Environment List Flattener

This folder contains an OpenTofu module that defines a combined list of applications and environments to be input to other modules for defining required app-environment combinations. 

<!-- BEGIN TF DOCS -->

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >=1.9 |

## Providers

No providers.

## Modules

No modules.

## Resources

No resources.

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_applications"></a> [applications](#input\_applications) | A list of applications to be hosted | `list(string)` | n/a | yes |
| <a name="input_environments"></a> [environments](#input\_environments) | A list of environments required for each application | `list(string)` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_app_env_list"></a> [app\_env\_list](#output\_app\_env\_list) | A combination of applications and their required environments |

<!-- END TF DOCS -->