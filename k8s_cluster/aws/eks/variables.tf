variable "vpc_id" {
  type = string
}

variable "private_subnets" {
  type = list(string)
  default = []
}

variable "environment" {
  default     = "development"
  description = "Kubernetes Cluster Environment"
}

variable "cluster_name" {
  default     = "pharmaledger-cluster"
  description = "Kubernetes Cluster Name"
}

variable "cluster_version" {
  default     = "1.15"
  description = "Kubernetes Cluster Version"
}

variable "region" {
  default = "eu-west-2"
}

variable "map_accounts" {
  description = "Additional AWS account numbers to add to the aws-auth configmap."
  type        = list(string)

  default = []
}

variable "map_roles" {
  description = "Additional IAM roles to add to the aws-auth configmap."
  type = list(object({
    rolearn  = string
    username = string
    groups   = list(string)
  }))

  default = []
}

variable "map_users" {
  description = "Additional IAM users to add to the aws-auth configmap."
  type = list(object({
    userarn  = string
    username = string
    groups   = list(string)
  }))

  default = []
}
