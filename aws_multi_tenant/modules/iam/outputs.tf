output "role_arns" {
  value = { for k, r in aws_iam_role.tenant_role : k => r.arn }
}

output "instance_profiles" {
  value = { for k, p in aws_iam_instance_profile.profile : k => p.name }
}
