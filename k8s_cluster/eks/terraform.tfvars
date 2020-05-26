cluster_name = "pl-cluster2"
cluster_version = "1.15"
vpc_name = "pl-cluster2-vpc"
environment = "development"
region = "eu-west-2"
map_users = [
  {
    userarn = "arn:aws:iam::912207196330:user/pharmaledger"
    username = "pharmaledger"
    groups = [
      "system:masters"
    ]
  },
]

