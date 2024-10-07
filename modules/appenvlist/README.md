# AWS Application-Environment List Flattener

This folder contains an OpenTofu module that defines a combined list of applications and environments to be input to other modules for defining required app-environment combinations. 


<!-- BEGIN_TF_DOCS -->
## Requirements

No requirements.

## Providers

No providers.

## Modules

No modules.

## Resources

No resources.

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_applications"></a> [applications](#input\_applications) | n/a | `list(string)` | n/a | yes |
| <a name="input_environments"></a> [environments](#input\_environments) | n/a | `list(string)` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_app_env_list"></a> [app\_env\_list](#output\_app\_env\_list) | n/a |
<!-- END_TF_DOCS -->
