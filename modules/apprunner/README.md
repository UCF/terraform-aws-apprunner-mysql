# OpenTofu Module for AWS AppRunner

This module creates AppRunner services in AWS. Podman is required to run `tofu test`. Ensure `podman machine init` and `podman machine start` have been commanded before running `tofu test`. Furthermore, the ECR and IAM modules must be applied for these tests to work.

<--BEGIN TF DOCS-->
## Requirements

The following requirements are needed by this module:

- <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) (>= 1.8.3)

- <a name="requirement_aws"></a> [aws](#requirement\_aws) (5.73.0)

## Providers

The following providers are used by this module:

- <a name="provider_aws"></a> [aws](#provider\_aws) (5.73.0)

## Modules

No modules.

## Resources

The following resources are used by this module:

- [aws_apprunner_auto_scaling_configuration_version.app_scaling](https://registry.terraform.io/providers/hashicorp/aws/5.73.0/docs/resources/apprunner_auto_scaling_configuration_version) (resource)
- [aws_apprunner_custom_domain_association.domains](https://registry.terraform.io/providers/hashicorp/aws/5.73.0/docs/resources/apprunner_custom_domain_association) (resource)
- [aws_apprunner_service.app_services](https://registry.terraform.io/providers/hashicorp/aws/5.73.0/docs/resources/apprunner_service) (resource)
- [aws_caller_identity.current](https://registry.terraform.io/providers/hashicorp/aws/5.73.0/docs/data-sources/caller_identity) (data source)

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

### <a name="input_ecr_repo_names"></a> [ecr\_repo\_names](#input\_ecr\_repo\_names)

Description: n/a

Type: `list(string)`

## Optional Inputs

The following input variables are optional (have default values):

### <a name="input_domain_name"></a> [domain\_name](#input\_domain\_name)

Description: n/a

Type: `string`

Default: `"cm.ucf.edu"`

### <a name="input_region"></a> [region](#input\_region)

Description: n/a

Type: `string`

Default: `"us-east-1"`

## Outputs

The following outputs are exported:

### <a name="output_DNS_records"></a> [DNS\_records](#output\_DNS\_records)

Description: n/a

### <a name="output_default_domain"></a> [default\_domain](#output\_default\_domain)

Description: n/a
<--END TF DOCS-->
