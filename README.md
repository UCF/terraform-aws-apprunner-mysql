# Terraform scripts for RDS, ECR, and App Runner


## Instructions

1. Ensure you are authenticated to your AWS account and have MySQL, OpenTofu, Podman, and Terragrunt installed on your command line

a. To authenticate to AWS, go to https://ucf-console.awsapps.com/start, select the correct account after logging in, and follow the instructions to get credentials for the appropriate access policy by clicking "Access Keys" and copying the exported credentials into your terminal

b. To install MySQL, see the following document: https://downloads.mysql.com/docs/mysql-installation-excerpt-8.0-en.pdf

c. To install OpenTofu, see: https://opentofu.org/docs/intro/install/

d. To install Terragrunt, see: https://davidbegin.github.io/terragrunt/

e. To install Podman, see: https://podman.io/docs/installation

2. Clone the Repository

3. Go to the modules folder (`cd modules`) 

4. Download `staging.tfvars` and/or `prod.tfvars` from SecretServer and place it in that folder

5. Run `terragrunt run-all apply -var-file="<insert absolute path to file>/<staging/prod>.tfvars`

6. Add the data to the database with a command like

`mysql -h <host> -u <username> -P 3306 -p <database_name> < <sqlfile>`

7. It is now necessary to push a container image to the ECR repository with the correct database url attached. To do so, change the `[ENV]_DATABASE_URL` secret in the app's Github Actions secret to a string of the form:

`mysql://admin:<outputted tofu password>@<DB Endpoint>:3306/<appname>_<envname>`

8. Commit a change to the `stages/dev` branch of the app repository so Github Actions can send the container image to ECR where App Runner will pull it from.

13. To destroy the infrastructure, run `terragrunt run-all destroy -var-file="<absolute path to file>/<staging/prod>.tfvars`

## Restore Snapshot Procedure

To restore an RDS instance from a specific snapshot, you will need to specify the snapshot identifier associated with the desired snapshot in your AWS account. The snapshot identifier is a unique identifier assigned to each snapshot created for your RDS instances.

To obtain the actual snapshot identifier, you can follow these steps:

    Log in to the AWS Management Console.
    Open the Amazon RDS service.
    Navigate to the "Snapshots" section.
    Locate the snapshot you want to restore from and note down its snapshot identifier.

The snapshot identifier typically follows a naming convention like rds:-. For example, if your RDS instance identifier is mydatabase and the snapshot was taken on January 1, 2023, the snapshot identifier might be rds:mydatabase-2023-01-01-12-34-56.

Once you have the snapshot identifier, you can specify it in your Terraform configuration's snapshot_identifier parameter to restore the RDS instance from that particular snapshot.
