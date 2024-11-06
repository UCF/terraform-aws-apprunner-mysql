# Application-Environment List Flattener

This module outputs a list of objects that combine applications and environments. The list can be used as an input for other modules in order to create environment-specific infrastructure for each application. Note that the terraform requirement below refers to the OpenTofu version used. 

<!-- BEGIN TF DOCS -->

## Requirements

The following requirements are needed by this module:

- <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) (>= 1.8.3)

## Providers

No providers.

## Modules

No modules.

## Resources

No resources.

## Required Inputs

The following input variables are required:

### <a name="input_applications"></a> [applications](#input\_applications)

Description: A list of applications to be hosted. Each application name must be less than 27 characters to comply with the MySQL database name length constraint.

Type: `list(string)`

### <a name="input_environments"></a> [environments](#input\_environments)

Description: A list of environments required for each application. Each environment name must be less than 5 characters to comply with the MySQL database name length constraint.

Type: `list(string)`

## Optional Inputs

No optional inputs.

## Outputs

The following outputs are exported:

### <a name="output_app_env_list"></a> [app\_env\_list](#output\_app\_env\_list)

Description: A combined list of objects naming required applications and their environments


<!-- END TF DOCS -->
