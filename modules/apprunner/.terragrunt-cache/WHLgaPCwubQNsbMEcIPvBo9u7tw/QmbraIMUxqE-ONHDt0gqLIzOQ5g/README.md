# OpenTofu Module for AWS AppRunner

This module creates AppRunner services in AWS. Podman is required to run `tofu test`. Ensure `podman machine init` and `podman machine start` have been commanded before running `tofu test`.

## Requirements

No requirements.

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | 5.72.1 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_ecr"></a> [ecr](#module\_ecr) | ../ecr | n/a |
| <a name="module_iam"></a> [iam](#module\_iam) | ../iam | n/a |

## Resources

| Name | Type |
|------|------|
| [aws_apprunner_auto_scaling_configuration_version.app_scaling](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/apprunner_auto_scaling_configuration_version) | resource |
| [aws_apprunner_service.app_services](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/apprunner_service) | resource |
| [aws_caller_identity.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_applications"></a> [applications](#input\_applications) | A list of available applications | `list(string)` | n/a | yes |
| <a name="input_environments"></a> [environments](#input\_environments) | A list of available environments | `list(string)` | n/a | yes |
| <a name="input_is_tofu_test_environment"></a> [is\_tofu\_test\_environment](#input\_is\_tofu\_test\_environment) | Determines if Tofu Test environment is active | `bool` | `false` | no |

## Outputs

No outputs.
