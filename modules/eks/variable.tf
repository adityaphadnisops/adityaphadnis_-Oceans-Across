variable "cluster_name" {
  description = "EKS cluster"
  type        = string
}

variable "cluster_version" {
  description = "Kubernetes version for the EKS cluster (e.g. 1.29)"
  type        = string
}

variable "subnet_ids" {
  description = "List of subnet IDs for EKS control plane and node groups"
  type        = list(string)

  validation {
    condition     = length(var.subnet_ids) > 0
    error_message = "subnet_ids must contain at least one subnet ID"
  }
}

variable "node_groups" {
  description = "Map of EKS node groups configuration"
  type = map(object({
    instance_types = list(string)
    capacity_type  = string
    scaling_config = object({
      desired_size = number
      max_size     = number
      min_size     = number
    })
  }))
}
