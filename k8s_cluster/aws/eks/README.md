# Provision an EKS Cluster

The Amazon Elastic Kubernetes Service (EKS) is the AWS service for deploying, managing, and scaling containerized applications with Kubernetes.

In this guide, you will deploy an EKS cluster using Terraform. Then, you will configure kubectl using Terraform output to deploy a Kubernetes dashboard on the cluster.

The final setup should be similar to following

![EKS](eks.jpg?raw=true)

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

In here, you will find six files used to provision security groups and an EKS cluster.

* `security-groups.tf` provisions the security groups used by the EKS cluster.
* `eks.tf` provisions all the resources (AutoScaling Groups, etc...) required to set up an EKS cluster in the private subnets and bastion servers to access the cluster using the AWS EKS Module.
* `outputs.tf` defines the output configuration.
* `versions.tf` sets the Terraform version to at least 0.12. It also sets versions for the providers used.
* `variables.tfvars` defines the variables
* `terraform.tfvars` Where you can set variables yourself.

## Initialize Terraform workspace

Initialize your Terraform workspace, which will download and configure the providers.

```
$ terraform init
```

## Provisioning and Destroying the EKS cluster
Lets assume we will provision a EKS cluster and we are naming it as `pl-cluster2`.
In the initialized directory, run terraform apply and review the planned actions. 
Your terminal output should indicate the plan is running and what resources will be created.
This process should take approximately 10 minutes. Upon successful application, your terminal prints the outputs defined in `outputs.tf`.

```
terraform plan -input=false -var=cluster_name=pl-cluster2 -out=pl-cluster2/terraform.tfplan -state=pl-cluster2/terraform.tfstate
terraform apply -state=pl-cluster2/terraform.tfstate pl-cluster2/terraform.tfplan
```

To destroy the cluster, in the initialized directory, run terraform destroy and review the planned actions. 
Your terminal output should indicate the plan is running and what resources will be deleted.

```
terraform destroy -auto-approve -state=pl-cluster2/terraform.tfstate
```

## Configure kubectl

Now that you've provisioned your EKS cluster `pl-cluster2`, you need to configure `kubectl`. Customize the following command with your `cluster_name` and `region` (the values from Terraform's output) you defined in `terraform.tfvars`. It will get the access credentials for your cluster and automatically configure `kubectl`.

```
aws eks --region eu-west-2 update-kubeconfig --name pl-cluster2
```

## Deploy and access Kubernetes Dashboard

This will guides you through deploying the Kubernetes Dashboard to your Amazon EKS cluster, complete with CPU and memory metrics. It also helps you to create an Amazon EKS administrator service account that you can use to securely connect to the dashboard to view and control your cluster.

### Step 1: Deploy the Kubernetes Metrics Server
The Kubernetes Metrics Server is an aggregator of resource usage data in your cluster, and it is not deployed by default in Amazon EKS clusters. The Kubernetes Dashboard uses the metrics server to gather metrics for your cluster, such as CPU and memory usage over time.

* Deploy the Metrics Server with the following command:
```
kubectl apply -f https://github.com/kubernetes-sigs/metrics-server/releases/download/v0.3.6/components.yaml
```
* Verify that the metrics-server deployment is running the desired number of pods with the following command.
```
kubectl get deployment metrics-server -n kube-system
```

Output
```
NAME             READY   UP-TO-DATE   AVAILABLE   AGE
metrics-server   1/1     1            1           6m
```

### Step 2: Deploy the dashboard
Use the following command to deploy the Kubernetes Dashboard.

```
kubectl apply -f https://raw.githubusercontent.com/kubernetes/dashboard/v2.0.0-beta8/aio/deploy/recommended.yaml
```

Output
```
namespace/kubernetes-dashboard created
serviceaccount/kubernetes-dashboard created
service/kubernetes-dashboard created
secret/kubernetes-dashboard-certs created
secret/kubernetes-dashboard-csrf created
secret/kubernetes-dashboard-key-holder created
configmap/kubernetes-dashboard-settings created
role.rbac.authorization.k8s.io/kubernetes-dashboard created
clusterrole.rbac.authorization.k8s.io/kubernetes-dashboard created
rolebinding.rbac.authorization.k8s.io/kubernetes-dashboard created
clusterrolebinding.rbac.authorization.k8s.io/kubernetes-dashboard created
deployment.apps/kubernetes-dashboard created
service/dashboard-metrics-scraper created
deployment.apps/dashboard-metrics-scraper created
```
### Step 3: Create an eks-admin service account and cluster role binding
By default, the Kubernetes Dashboard user has limited permissions. In this section, you create an eks-admin service account and cluster role binding that you can use to securely connect to the dashboard with admin-level permissions. For more information, see [Managing Service Accounts](https://kubernetes.io/docs/admin/service-accounts-admin/) in the Kubernetes documentation.

```
kubectl apply -f k8s/eks-admin-service-account.yaml
```
Output:

```
serviceaccount "eks-admin" created
clusterrolebinding.rbac.authorization.k8s.io "eks-admin" created
```
### Step 4: Connect to the dashboard
Now that the Kubernetes Dashboard is deployed to your cluster, and you have an administrator service account that you can use to view and control your cluster, you can connect to the dashboard with that service account.

To connect to the Kubernetes dashboard

* Retrieve an authentication token for the eks-admin service account. Copy the `<authentication_token>` value from the output. You use this token to connect to the dashboard.
  
```
kubectl -n kube-system describe secret $(kubectl -n kube-system get secret | grep eks-admin | awk '{print $1}')
```

Output:

```
Name:         eks-admin-token-b5zv4
Namespace:    kube-system
Labels:       <none>
Annotations:  kubernetes.io/service-account.name=eks-admin
              kubernetes.io/service-account.uid=bcfe66ac-39be-11e8-97e8-026dce96b6e8

Type:  kubernetes.io/service-account-token

Data
====
ca.crt:     1025 bytes
namespace:  11 bytes
token:      <authentication_token>
```

* Start the kubectl proxy.
  
```
kubectl proxy
```

* To access the dashboard endpoint, open [the link](http://localhost:8001/api/v1/namespaces/kubernetes-dashboard/services/https:kubernetes-dashboard:/proxy/#!/login) with a web browser.
* Choose Token, paste the `<authentication_token>` output from the previous command into the Token field, and choose SIGN IN.
  


### Step 5: Next steps
After you have connected to your Kubernetes Dashboard, you can view and control your cluster using your `eks-admin` service account. For more information about using the dashboard, see the [project documentation](https://github.com/kubernetes/dashboard) on GitHub.

## References
* https://learn.hashicorp.com/terraform/kubernetes/provision-eks-cluster
* https://docs.aws.amazon.com/eks/latest/userguide/dashboard-tutorial.html