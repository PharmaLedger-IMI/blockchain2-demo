cluster_name = "pl-cluster2"
cluster_version = "1.15"
vpc_id = "vpc-0551f5ff8bc0f1e5d"
private_subnets = [
  "subnet-0defb9789bc142746",
  "subnet-033e41d365bcd440e",
  "subnet-05c51f83d1156cedb",
]
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

