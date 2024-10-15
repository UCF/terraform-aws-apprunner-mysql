# ECR Repositories based on App-Env List combination

This module uses the appenvlist module in order to spin up a number of ECR repositories based on the application names and environment names fed to the first appenvlist module.


## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >=1.9 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | 5.70.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_appenvlist"></a> [appenvlist](#module\_appenvlist) | ../appenvlist | n/a |

## Resources

| Name | Type |
|------|------|
| [aws_ecr_repository.app_repos](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecr_repository) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_applications"></a> [applications](#input\_applications) | List of application names | `list(string)` | n/a | yes |
| <a name="input_environments"></a> [environments](#input\_environments) | List of application environments | `list(string)` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_ecr_repo_names"></a> [ecr\_repo\_names](#output\_ecr\_repo\_names) | Names of ECR repositories |