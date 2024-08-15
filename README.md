# Terraform scripts for RDS, ECR, and App Runner


## Instructions

1. Ensure you are authenticated to your AWS account

2. Clone the Repository

3. Go to the infrastructure folder (`cd infrastructure`) 

4. Download `terraform.tfvars` from SecretServer

5. Run `tofu init` and then `tofu apply`

6. Check the configuration and confirm the infrastructure before typing 'yes'

7. The process will fail with errors. If the errors are all related to AppRunner, then the process has succeeded. It is now necessary to push a container image to the ECR repository with the correct database url attached.
