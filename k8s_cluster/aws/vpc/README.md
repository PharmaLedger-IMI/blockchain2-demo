# Provision a VPC

Amazon Virtual Private Cloud (Amazon VPC) lets you provision a logically isolated section of the AWS Cloud where you can launch AWS resources in a virtual network that you define. 
In this guide, you will deploy a VPC using Terraform. It will provision a VPC, subnets and availability zones using the AWS VPC Module. A new VPC is created for this guide so it doesn't impact your existing cloud environment and resources.


## Prerequisites
The guide assumes some basic familiarity with Kubernetes and kubectl but does not assume any pre-existing deployment.

It also assumes that you are familiar with the usual Terraform plan/apply workflow. If you're new to Terraform itself, refer first to the [Getting Started](https://learn.hashicorp.com/terraform?track=gcp#gcp) guide.

For this guide, you will need:

* an AWS account
* a configured AWS CLI: In order for Terraform to run operations on your behalf, you must install and configure the AWS CLI tool. To install the AWS CLI, follow [these instructions](https://docs.aws.amazon.com/cli/latest/userguide/install-cliv2-mac.html) or choose a package manager based on your operating system.
* AWS IAM Authenticator: To install follow [these instructions](https://docs.aws.amazon.com/eks/latest/userguide/install-aws-iam-authenticator.html)
* `kubectl`: To install follow [these instructions](https://docs.aws.amazon.com/eks/latest/userguide/install-kubectl.html)
* wget (required for the terraform `eks` module): Install based on you OS

After you've installed the AWS CLI, configure it by running aws configure.

When prompted, enter your AWS Access Key ID, Secret Access Key, region and output format.

```
aws configure
AWS Access Key ID [None]: YOUR_AWS_ACCESS_KEY_ID
AWS Secret Access Key [None]: YOUR_AWS_SECRET_ACCESS_KEY
Default region name [None]: YOUR_AWS_REGION
Default output format [None]: json
```

If you don't have an AWS Access Credentials, create your AWS Access Key ID and Secret Access Key by navigating to your [service credentials](https://console.aws.amazon.com/iam/home?#/security_credentials) in the IAM service on AWS. Click "Create access key" here and download the file. This file contains your access credentials.

Your default region can be found in the AWS Web Management Console beside your username. Select the region drop down to find the region name (eg. us-east-1) corresponding with your location.

## Terraform files

In here, you will find six files used to provision a VPC.

* `vpc.tf` provisions all the resources required to set up a VPC using the AWS VPC Module.
* `outputs.tf` defines the output configuration.
* `versions.tf` sets the Terraform version to at least 0.12. It also sets versions for the providers used.
* `variables.tfvars` defines the variables
* `terraform.tfvars` Where you can set variables yourself.

## Initialize Terraform workspace

Initialize your Terraform workspace, which will download and configure the providers.

```
$ terraform init
```

## Provision the VPC
In the initialized directory, run terraform apply and review the planned actions. Your terminal output should indicate the plan is running and what resources will be created.

```
terraform apply
```

## Destroy the VPC
In the initialized directory, run terraform destroy and review the planned actions. Your terminal output should indicate the plan is running and what resources will be deleted.

```
terraform destroy
```
