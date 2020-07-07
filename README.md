# Blockchian Demo 2

This repository contains a PoC of Anchor API.
This PoC has following endpoints:

* POST /data_anchors - Create a new data anchor 
* GET - /data_anchors /{anchorId} - Get an anchor by its identifier 
* PUT - /data_anchors /{anchorId} - Update an anchor by its identifier

API documentation can be found here [Swagger](anchor_api/swagger.yaml)

For this PoC Anchor API you can use one of the following blockchain network to store anchors using smart contract.

* Quorum
* Ethereum (has issue with run Out of Gas)

To run this PoC you will need following:

* an AWS account (We have created an AWS account for the PoC, please contact to get the `AWS Access Key ID` and `AWS Secret Access Key` in case you need)
* a configured AWS CLI: In order for Terraform to run operations on your behalf, you must install and configure the AWS CLI tool. To install the AWS CLI, follow [these instructions](https://docs.aws.amazon.com/cli/latest/userguide/install-cliv2-mac.html) or choose a package manager based on your operating system.
* AWS IAM Authenticator: To install follow [these instructions](https://docs.aws.amazon.com/eks/latest/userguide/install-aws-iam-authenticator.html)
* `kubectl`: To install follow [these instructions](https://docs.aws.amazon.com/eks/latest/userguide/install-kubectl.html)
* `wget` (required for the terraform `eks` module): Install based on you OS
* A Kubernetes cluster with Kubernetes v1.15
* A Quorum / Ethereum network deployed in the Kubernetes cluster

After you've installed the AWS CLI, configure it by running aws configure. When prompted, enter your AWS Access Key ID, Secret Access Key, region and output format.

```
aws configure
AWS Access Key ID [None]: YOUR_AWS_ACCESS_KEY_ID
AWS Secret Access Key [None]: YOUR_AWS_SECRET_ACCESS_KEY
Default region name [None]: YOUR_AWS_REGION
Default output format [None]: json
```

If you don't have an AWS Access Credentials, create your AWS Access Key ID and Secret Access Key by navigating to your [service credentials](https://console.aws.amazon.com/iam/home?#/security_credentials) in the IAM service on AWS. Click "Create access key" here and download the file. This file contains your access credentials.
Your default region can be found in the AWS Web Management Console beside your username. Select the region drop down to find the region name (eg. us-east-1) corresponding with your location.

# Anchor API with Quorum
## Setup a Kubernetes cluster
* Choose our *pl-cluster2*
```
aws eks --region eu-west-2 update-kubeconfig --name pl-cluster2
```
* If you want to deploy your own Kubernetes cluster you can follow this [guideline](k8s_cluster/eks)

## Deploy Quorum network
Clone our [blockchain2-demo](https://github.com/PharmaLedger-IMI/blockchain2-demo) (this) repo then follow below steps:

Run following command in `blockchain2-demo` directory one by one
```
kubectl apply -f quorum_network/k8s
kubectl apply -f quorum_network/k8s/deployments
```
Run following command to list all the services that are running.
```
kubectl get services
```

Above command will output something like below, and please note down `ClusterIP` of `quorum-node1`
```
NAME           TYPE           CLUSTER-IP       EXTERNAL-IP                                                               PORT(S)                                                                        AGE
kubernetes     ClusterIP      172.20.0.1       <none>                                                                    443/TCP                                                                        131m
quorum-node1   LoadBalancer   172.20.179.183   a241642f88a8d4f19bc145eca395f40b-52798287.eu-west-2.elb.amazonaws.com     9001:30501/TCP,9080:31109/TCP,8545:32375/TCP,30303:30943/TCP,50401:32577/TCP   122m
quorum-node2   LoadBalancer   172.20.102.53    a4e2b95d0f4e54bc092b2940e64f3260-780403947.eu-west-2.elb.amazonaws.com    9001:32522/TCP,9080:30328/TCP,8545:30053/TCP,30303:31806/TCP,50401:32059/TCP   122m
quorum-node3   LoadBalancer   172.20.35.177    a3c84060dc3e043229d4764fedb9c9d4-228948034.eu-west-2.elb.amazonaws.com    9001:32401/TCP,9080:31073/TCP,8545:30365/TCP,30303:30474/TCP,50401:31578/TCP   122m
quorum-node4   LoadBalancer   172.20.64.242    ac6924ee3b1cf4ba4b4e08941bab14aa-1675415563.eu-west-2.elb.amazonaws.com   9001:31719/TCP,9080:31572/TCP,8545:32215/TCP,30303:32028/TCP,50401:31111/TCP   122m
```

## Deploy Anchor API
Clone our [blockchain2-demo](https://github.com/PharmaLedger-IMI/blockchain2-demo) (this) repo then follow below steps:

Run following command in `blockchain2-demo` directory to deploy the Anchor API which will use Quorum network. 
Use `ClusterIP` of `quorum-node1` as host part of `env.web3_provider`.
Use `0x66d66805E29EaB59901f8B7c4CAE0E38aF31cb0e` as value of `env.web3_account`
```
helm install --set env.web3_provider=http://172.20.179.183:8545 --set env.web3_account=0x66d66805E29EaB59901f8B7c4CAE0E38aF31cb0e anchor-api-quorum anchor_api/helm-charts/
```

# Anchor API with Ethereum
## Setup a Kubernetes cluster
* Choose our *pl-cluster3*
```
aws eks --region eu-west-2 update-kubeconfig --name pl-cluster3
```
* If you want to deploy your own Kubernetes cluster you can follow this [guideline](k8s_cluster/eks)

## Deploy Ethereum network
Clone our [blockchain3-demo](https://github.com/PharmaLedger-IMI/blockchain3-demo) repo then follow below steps:

Run following command in `blockchain3-demo` directory:
```
helm install my-eth-pharmaledger stable/ethereum -f values.yaml
kubectl apply -f ethereum-geth-tx-loadbalancer.yaml
```
Run following command to list all the services that are running.
```
kubectl get services
```

Above command will output something like below, and please note down `ClusterIP` of `*-ethereum-geth-tx`
```
kubernetes                              ClusterIP      172.20.0.1       <none>                                                                    443/TCP                         12h
my-eth-pharmaledger-ethereum-bootnode   ClusterIP      None             <none>                                                                    30301/UDP,80/TCP                135m
my-eth-pharmaledger-ethereum-ethstats   LoadBalancer   172.20.56.122    a54fc4da99005430baae72cf5bfb0c70-739739716.eu-west-2.elb.amazonaws.com    80:31661/TCP                    135m
my-eth-pharmaledger-ethereum-geth-tx    ClusterIP      172.20.217.232   <none>                                                                    8545/TCP,8546/TCP               135m
```

## Deploy Anchor API
Clone our [blockchain2-demo](https://github.com/PharmaLedger-IMI/blockchain2-demo) (this) repo then follow below steps:

Run following command in `blockchain2-demo` directory to deploy the Anchor API which will use Ethereum network. 
Use `ClusterIP` of `quorum-node1` as host part of `env.web3_provider`.
Use `0x66d66805E29EaB59901f8B7c4CAE0E38aF31cb0e` as value of `env.web3_account`.
Use `lst7upm` as value of `env.web3_password`.
```
helm install --set env.web3_provider=http://172.20.217.232:8545 --set env.web3_account=0x3852360755845889E675C4b683f3F26bf8f12aeA --set env.web3_password=lst7upm anchor-api-ethereum anchor_api/helm-charts/
```