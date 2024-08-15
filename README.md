# Terraform scripts for RDS, ECR, and App Runner


## Instructions

1. Ensure you are authenticated to your AWS account

2. Clone the Repository

3. Go to the infrastructure folder (`cd infrastructure`) 

4. Run `tofu apply`

5. Check the configuration and confirm the infrastructure before typing 'yes'

6. The process will fail with errors. If the errors are all related to AppRunner, then the process has succeeded. It is now necessary to push a container image to the ECR repository with the correct database url attached.
