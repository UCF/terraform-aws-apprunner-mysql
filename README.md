# Terraform scripts for RDS, ECR, and App Runner


## Instructions

1. Ensure you are authenticated to your AWS account and have MySQL and OpenTofu installed on your command line

2. Clone the Repository

3. Go to the infrastructure folder (`cd infrastructure`) 

4. Download `terraform.tfvars` from SecretServer and place it in that folder

5. Run `tofu init` and then `tofu apply`

6. Check the configuration and confirm the infrastructure before typing 'yes' (If the apply succeeded, everything except for the App Runner services and the containers in the ECR repository will have been created)

7. It is now necessary to push a container image to the ECR repository with the correct database url attached. To do so, change the `[ENV]_DATABASE_URL` secret in the app's Github Actions secret to a string of the form:

`mysql://admin:password@cm-appfolio-db.c9o06ok6uz10.us-east-1.rds.amazonaws.com:3306/announcements_qa`

Replace the URL in the middle with the proper endpoint of your database and replace "announcements" with your app name and "qa" with the environment name.

8. Commit a change to the `stages/dev` branch of the app repository so Github Actions can send the container image to ECR where App Runner will pull it from.

9. Go to the apprunner folder (`cd ../apprunner`)

10. Run `tofu init` and then `tofu apply` to set up the App Runner IAM

11. Copy the output value within the quotes and go to the service sub-folder (`cd service`)

12. Run `tofu init` and then `tofu apply` to set up the App Runner services, paste the copied output into the variable

13. When a change is made to the application code, go to App Runner and click the deploy button in the application of choice in order to have the container loaded into the environment 
