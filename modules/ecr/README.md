# ECR Repositories based on App-Env List combination

This module uses the appenvlist module in order to spin up a number of ECR repositories based on the application names and environment names fed to the first appenvlist module. Note that the Terraform requirement refers to the OpenTofu version required.


<-- BEGIN TF DOCS -->

## Requirements

The following requirements are needed by this module:

- <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) (>= 1.8.3)

- <a name="requirement_aws"></a> [aws](#requirement\_aws) (5.73.0)

- <a name="requirement_null"></a> [null](#requirement\_null) (3.2.3)

## Providers

The following providers are used by this module:

- <a name="provider_aws"></a> [aws](#provider\_aws) (5.73.0)

- <a name="provider_null"></a> [null](#provider\_null) (3.2.3)

## Modules

No modules.

## Resources

The following resources are used by this module:

- [aws_ecr_repository.repositories](https://registry.terraform.io/providers/hashicorp/aws/5.73.0/docs/resources/ecr_repository) (resource)
- [aws_ecr_repository_policy.repositories_policy](https://registry.terraform.io/providers/hashicorp/aws/5.73.0/docs/resources/ecr_repository_policy) (resource)
- [null_resource.check_ecr_images](https://registry.terraform.io/providers/hashicorp/null/3.2.3/docs/resources/resource) (resource)
- [null_resource.push_default_image](https://registry.terraform.io/providers/hashicorp/null/3.2.3/docs/resources/resource) (resource)

## Required Inputs

The following input variables are required:

### <a name="input_app_env_list"></a> [app\_env\_list](#input\_app\_env\_list)

Description: The App-Env List imported from the appenvlist module

Type:

```hcl
list(object({
    app = string
    env = string
  }))
```

## Optional Inputs

The following input variables are optional (have default values):

### <a name="input_should_force_delete"></a> [should\_force\_delete](#input\_should\_force\_delete)

Description: Determines if ECR repositories should be force-deleted on teardown. Should be false for production

Type: `bool`

Default: `true`

## Outputs

The following outputs are exported:

### <a name="output_ecr_repo_names"></a> [ecr\_repo\_names](#output\_ecr\_repo\_names)

Description: Names of ECR repositories

<--END TF DOCS-->
