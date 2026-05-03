AWS Multi-Tenant Terraform

This project provisions a secure, multi-tenant AWS environment using Terraform modules:

- VPC (2 AZs, public and private subnets)
- EC2 instances (company, bureau, employee) — isolated per tenant
- RDS PostgreSQL in private subnets (not publicly accessible)
- S3 bucket with versioning and encryption
- IAM roles and least-privilege policies for each tenant
- Security groups to isolate tenant traffic

Modules: `vpc`, `security`, `ec2`, `rds`, `s3`, `iam`.

Fill `terraform.tfvars` based on `terraform.tfvars.example` and run:

```bash
terraform init
terraform plan
terraform apply
```

Be sure to review variables and secrets before applying in production.
