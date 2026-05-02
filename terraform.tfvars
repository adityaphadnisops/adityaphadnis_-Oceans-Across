cluster_name    = "demo-eks"
cluster_version = "1.29"

vpc_cidr = "10.0.0.0/16"

availability_zones = ["ap-south-1a", "ap-south-1b"]

public_subnet_cidrs = [
  "10.0.1.0/24",
  "10.0.2.0/24"
]

private_subnet_cidrs = [
  "10.0.101.0/24",
  "10.0.102.0/24"
]

node_groups = {
  on_demand = {
    instance_types = ["t3.medium"]
    capacity_type  = "ON_DEMAND"
    scaling_config = {
      desired_size = 2
      min_size     = 1
      max_size     = 3
    }
  }

  spot = {
    instance_types = ["t3.medium", "t3.large"]
    capacity_type  = "SPOT"
    scaling_config = {
      desired_size = 1
      min_size     = 0
      max_size     = 5
    }
  }
}
