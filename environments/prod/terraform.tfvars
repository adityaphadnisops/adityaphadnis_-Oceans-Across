project = "payroll-prod"
region  = "us-east-1"
env     = "prod"

# Must provide a real Secrets Manager ARN via CI (do NOT commit the real ARN to VCS)
db_secret_arn = "arn:aws:secretsmanager:us-east-1:123456789012:secret:payroll-prod-db-XYZ789"

# In production we recommend creating the RDS instance out-of-band and importing into Terraform,
# or running a secure bootstrap job that creates the DB using Secrets Manager without storing secrets in TF state.
