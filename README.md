# Terragrunt-wrapped OpenTofu scripts for RDS, ECR, and AppRunner including IAM

## Instructions

1. Ensure you are authenticated to your AWS account and have MySQL, OpenTofu, Podman, Terragrunt, and the AWS CLI V2 installed on your command line

    a. To authenticate to AWS, go to https://ucf-console.awsapps.com/start, select the correct account after logging in, and follow the instructions to get credentials for the appropriate access policy by clicking "Access Keys" and copying the exported credentials into your terminal

    b. To install MySQL, see the following document: https://downloads.mysql.com/docs/mysql-installation-excerpt-8.0-en.pdf

    c. To install OpenTofu, see: https://opentofu.org/docs/intro/install/

    d. To install Terragrunt, see: https://davidbegin.github.io/terragrunt/ [Note: Installing Terraform is not required as we have OpenTofu]

    e. To install Podman, see: https://podman.io/docs/installation

    f. To install the AWS CLIV2, see: https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html

2. Clone the Repository

3. Go to the modules folder (`cd modules`) 

4. Download `<environment>.tfvars` (e.g., `prod.tfvars`) from SecretServer and place it in that folder

[Optional: Run `terragrunt run-all plan -var-file="<insert absolute path to file>/<environment>.tfvars` to see what the changes will be before you apply them]

5. Run `terragrunt run-all apply -var-file="<insert absolute path to file>/<environment>.tfvars`

6. Add the data to the database with a command like

`mysql -h <host> -u <username> -P 3306 -p <database_name> < <sqlfile>`

7. It is now necessary to push a container image to the ECR repository with the correct database url attached. To do so, change the `[ENV]_DATABASE_URL` secret in the app's Github Actions secret to a string of the form:

`mysql://admin:<outputted tofu password>@<DB Endpoint>:3306/<appname>-<envname>`

8. Commit a change to the `stages/dev` branch, for example, of the app repository so Github Actions can send the container image to ECR where App Runner will pull it from.

## Making changes

To make changes to the infrastructure, please do Test-Driven Development with OpenTofu (i.e., write a test that verifies the change, and then write the change) to prevent the codebase from becoming legacy.

After making the change, DO NOT run `terragrunt run-all destroy` as it will DESTROY ALL INFRASTRUCTURE! 

Instead, run `terragrunt run-all apply -var-file="<insert absolute path to file>/<environment>/tfvars`

This will destroy infrastructure that you have taken out (e.g., an application) while preserving what is still needed.

## Destroying the infrastructure

To destroy ALL infrastructure, run `terragrunt run-all destroy -var-file="<absolute path to file>/<staging/prod>.tfvars`

## Restore Snapshot Procedure

To restore an RDS instance from a specific snapshot, you will need to specify the snapshot identifier associated with the desired snapshot in your AWS account. The snapshot identifier is a unique identifier assigned to each snapshot created for your RDS instances.

To obtain the actual snapshot identifier, you can follow these steps:

    Log in to the AWS Management Console.
    Open the Amazon RDS service.
    Navigate to the "Snapshots" section.
    Locate the snapshot you want to restore from and note down its snapshot identifier.

The snapshot identifier typically follows a naming convention like rds:-. For example, if your RDS instance identifier is mydatabase and the snapshot was taken on January 1, 2023, the snapshot identifier might be rds:mydatabase-2023-01-01-12-34-56.

Once you have the snapshot identifier, you can specify it in your Terraform configuration's snapshot_identifier parameter to restore the RDS instance from that particular snapshot.
