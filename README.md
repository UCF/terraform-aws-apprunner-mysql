# Bootstrapped TofuGrunt Kubernetes

A system that creates an entire EKS cluster from scratch in Kubernetes. 
Automatically creates the remote state backend

### Setup

- Ensure you have OpenTofu installed with a version of at least 1.7 [here](https://opentofu.org/docs/intro/install/)

- Ensure you have Terragrunt installed (if using a Debian-based Linux, use the method with taking the binary from the Github Release file instead of using Homebrew) [here](https://davidbegin.github.io/terragrunt/)

- Ensure your AWS Access credentials are properly configured

### Steps to create the infrastructure

Clone the repo

Go into the "infrastructure" folder and type the following commands

```
tofu init
tofu apply -target "random_shuffle.az"
tofu apply
```

Then go into the "kubernetes" folder and type the following commands

```
tofu init
tofu apply
```

### Steps to destroy the infrastructure

Run the following commands from the folder you wish to destroy from. Do not destroy the infrastructure folder resources without destroying the application and kubernetes resources first.

From the kubernetes folder:
`tofu destroy`

From the infrastructure folder:
```
tofu destroy -target "aws_eks_cluster.main"
tofu destroy
```

If the destruction does not work, attempt to delete the RDS instance manually in AWS and then try again.


