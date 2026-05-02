output "instance_profile_names" {
  description = "IAM instance profile names for tenant backend instances"
  value       = [for tenant in var.tenant_names : aws_iam_instance_profile.tenant[tenant].name]
}

output "role_names" {
  description = "IAM role names created for tenant isolation"
  value       = [for tenant in var.tenant_names : aws_iam_role.tenant[tenant].name]
}
