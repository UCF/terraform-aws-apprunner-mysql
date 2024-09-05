# Terraform scripts for RDS, ECR, and App Runner


## Instructions

1. Ensure you are authenticated to your AWS account and have MySQL, OpenTofu, and Terragrunt installed on your command line

a. To authenticate to AWS, go to https://ucf-console.awsapps.com/start, select the correct account after logging in, and follow the instructions to get credentials for the appropriate access policy by clicking "Access Keys" and copying the exported credentials into your terminal

b. To install MySQL, see the following document: https://downloads.mysql.com/docs/mysql-installation-excerpt-8.0-en.pdf

c. To install OpenTofu, see: https://opentofu.org/docs/intro/install/

d. To install Terragrunt, see: https://davidbegin.github.io/terragrunt/

2. Clone the Repository

3. Go to the infrastructure folder (`cd infrastructure`) 

4. Download `terraform.tfvars` from SecretServer and place it in that folder

5. Run `terragrunt init` and then `terragrunt apply`

6. Check the configuration and confirm the infrastructure before typing 'yes' (If the apply succeeded, everything except for the App Runner services and the containers in the ECR repository will have been created)

7. It is now necessary to push a container image to the ECR repository with the correct database url attached. To do so, change the `[ENV]_DATABASE_URL` secret in the app's Github Actions secret to a string of the form:

`mysql://admin:password@cm-appfolio-db.c9o06ok6uz10.us-east-1.rds.amazonaws.com:3306/announcements_qa`

Replace the URL in the middle with the proper endpoint of your database and replace "announcements" with your app name and "qa" with the environment name.

8. Commit a change to the `stages/dev` branch of the app repository so Github Actions can send the container image to ECR where App Runner will pull it from.

9. Go to the apprunner folder (`cd ../apprunner`)

10. Run `terragrunt init` and then `terragrunt apply` to set up the App Runner IAM

11. Go to the service sub-folder (`cd service`)

12. Run `terragrunt init` and then `terragrunt apply` to set up the App Runner services, paste the copied output into the variable

13. To destroy the infrastructure, go to each folder in reverse (service, apprunner, then infrastructure) and type `terragrunt destroy` 
