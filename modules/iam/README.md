# ECR Repositories based on App-Env List combination

This module creates the AppRunner IAM role and ECR access policy as well as a policy attachment in order to manage AppRunner's access to the ECR repositories.

<--BEGIN TF DOCS-->
## Requirements

The following requirements are needed by this module:

- <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) (1.8.3)

- <a name="requirement_aws"></a> [aws](#requirement\_aws) (5.74.0)

## Providers

The following providers are used by this module:

- <a name="provider_aws"></a> [aws](#provider\_aws) (5.73.0)

## Modules

The following Modules are called:

### <a name="module_github-oidc"></a> [github-oidc](#module\_github-oidc)

Source: github.com/terraform-module/terraform-aws-github-oidc-provider

Version: v2.2.1

## Resources

The following resources are used by this module:

- [aws_iam_policy.ecr_access_policy](https://registry.terraform.io/providers/hashicorp/aws/5.74.0/docs/resources/iam_policy) (resource)
- [aws_iam_policy.github_ecr_access](https://registry.terraform.io/providers/hashicorp/aws/5.74.0/docs/resources/iam_policy) (resource)
- [aws_iam_role.apprunner_role](https://registry.terraform.io/providers/hashicorp/aws/5.74.0/docs/resources/iam_role) (resource)
- [aws_iam_role.ecraccess_role](https://registry.terraform.io/providers/hashicorp/aws/5.74.0/docs/resources/iam_role) (resource)
- [aws_iam_role_policy_attachment.apprunner_ecr_policy_attach](https://registry.terraform.io/providers/hashicorp/aws/5.74.0/docs/resources/iam_role_policy_attachment) (resource)
- [aws_iam_role_policy_attachment.ecraccess_attach](https://registry.terraform.io/providers/hashicorp/aws/5.74.0/docs/resources/iam_role_policy_attachment) (resource)
- [aws_iam_policy_document.github_actions_assume_role](https://registry.terraform.io/providers/hashicorp/aws/5.74.0/docs/data-sources/iam_policy_document) (data source)
- [aws_iam_policy_document.githubecrdoc](https://registry.terraform.io/providers/hashicorp/aws/5.74.0/docs/data-sources/iam_policy_document) (data source)

## Required Inputs

No required inputs.

## Optional Inputs

The following input variables are optional (have default values):

### <a name="input_region"></a> [region](#input\_region)

Description: n/a

Type: `string`

Default: `"us-east-1"`

## Outputs

The following outputs are exported:

### <a name="output_apprunner_access_role_arn"></a> [apprunner\_access\_role\_arn](#output\_apprunner\_access\_role\_arn)

Description: The ARN of the AppRunner access IAM role

### <a name="output_github_access_role_arn"></a> [github\_access\_role\_arn](#output\_github\_access\_role\_arn)

Description: The ARN of the ECR access IAM role

### <a name="output_oidc_arn"></a> [oidc\_arn](#output\_oidc\_arn)

Description: Github OIDC ARN
<--END TF DOCS-->
