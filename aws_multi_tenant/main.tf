local {
  azs = length(var.availability_zones) >= 2 ? var.availability_zones : slice(data.aws_availability_zones.available.names,0,2)
}

locals {
  # Load DB credentials from an existing Secrets Manager secret (JSON with keys: username,password).
  # This must exist; Terraform will fail if the secret is missing. DO NOT store secrets in TF state/variables.
  db_creds = jsondecode(data.aws_secretsmanager_secret_version.db_version[0].secret_string)
}

module "vpc" {
  source              = "./modules/vpc"
  name                = "${var.project}-vpc"
  cidr                = var.vpc_cidr
  public_subnet_cidrs = var.public_subnet_cidrs
  private_subnet_cidrs= var.private_subnet_cidrs
  azs                 = local.azs
  region              = var.region
  tags = merge(var.tags, { Environment = var.env })
}

module "security" {
  source = "./modules/security"
  vpc_id = module.vpc.vpc_id
  tenants = var.tenants
  admin_cidr = var.admin_cidr
}

module "kms" {
  source = "./modules/kms"
  alias_name = "${var.project}-key"
  tags = merge(var.tags, { Environment = var.env })
}

# IAM roles for tenants (grant KMS usage via grants after roles exist)
module "iam" {
  source      = "./modules/iam"
  tenants     = var.tenants
  bucket_arn  = ""
  kms_key_arn = module.kms.key_arn
  kms_key_id  = module.kms.key_id
  db_secret_arn = var.db_secret_arn
  project     = var.project
  tags        = merge(var.tags, { Environment = var.env })
}

module "s3" {
  source = "./modules/s3"
  name   = "${var.project}-bucket"
  kms_key_id = module.kms.key_id
  tenants = var.tenants
  tenant_role_arns = module.iam.role_arns
  tags = merge(var.tags, { Environment = var.env })
}

module "rds" {
  source = "./modules/rds"
  identifier = "${var.project}-db"
  username = local.db_creds.username
  password = local.db_creds.password
  vpc_security_group_ids = [module.security.rds_sg_id]
  subnet_ids = module.vpc.private_subnets
  kms_key_id = module.kms.key_id
  backup_retention_period = 7
  deletion_protection = true
  enable_multi_az = false
  tags = merge(var.tags, { Environment = var.env })
}

resource "random_string" "suffix" {
  length  = 4
  upper   = false
  special = false
}

module "ec2_company" {
  source = "./modules/ec2"
  name   = "company"
  ami_filter = {
    name = "amzn2-ami-hvm-*-x86_64-gp2"
  }
  instance_type = var.instance_type
  subnet_id = module.vpc.private_subnets[0]
  security_group_ids = [module.security.tenant_sg_ids["company"]]
  iam_instance_profile = module.iam.instance_profiles["company"]
  tags = merge(var.tags, { Environment = var.env, Tenant = "company" })
}

module "ec2_bureau" {
  source = "./modules/ec2"
  name   = "bureau"
  ami_filter = {
    name = "amzn2-ami-hvm-*-x86_64-gp2"
  }
  instance_type = var.instance_type
  subnet_id = module.vpc.private_subnets[1]
  security_group_ids = [module.security.tenant_sg_ids["bureau"]]
  iam_instance_profile = module.iam.instance_profiles["bureau"]
  tags = merge(var.tags, { Environment = var.env, Tenant = "bureau" })
}

module "ec2_employee" {
  source = "./modules/ec2"
  name   = "employee"
  ami_filter = {
    name = "amzn2-ami-hvm-*-x86_64-gp2"
  }
  instance_type = var.instance_type
  subnet_id = module.vpc.private_subnets[0]
  security_group_ids = [module.security.tenant_sg_ids["employee"]]
  iam_instance_profile = module.iam.instance_profiles["employee"]
  tags = merge(var.tags, { Environment = var.env, Tenant = "employee" })
}

# Monitoring: SNS topic for alerts and CloudWatch alarms for EC2 and RDS
resource "aws_sns_topic" "alerts" {
  name = "${var.project}-alerts-${var.env}"
  tags = merge(var.tags, { Environment = var.env })
}

resource "aws_cloudwatch_metric_alarm" "ec2_cpu_company" {
  alarm_name          = "ec2-company-cpu-high"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = 300
  statistic           = "Average"
  threshold           = 80
  alarm_description   = "High CPU on company instance"
  alarm_actions       = [aws_sns_topic.alerts.arn]
  dimensions = {
    InstanceId = module.ec2_company.instance_id
  }
}

resource "aws_cloudwatch_metric_alarm" "ec2_cpu_bureau" {
  alarm_name          = "ec2-bureau-cpu-high"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = 300
  statistic           = "Average"
  threshold           = 80
  alarm_description   = "High CPU on bureau instance"
  alarm_actions       = [aws_sns_topic.alerts.arn]
  dimensions = {
    InstanceId = module.ec2_bureau.instance_id
  }
}

resource "aws_cloudwatch_metric_alarm" "ec2_cpu_employee" {
  alarm_name          = "ec2-employee-cpu-high"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = 300
  statistic           = "Average"
  threshold           = 80
  alarm_description   = "High CPU on employee instance"
  alarm_actions       = [aws_sns_topic.alerts.arn]
  dimensions = {
    InstanceId = module.ec2_employee.instance_id
  }
}

resource "aws_cloudwatch_metric_alarm" "rds_connections" {
  alarm_name          = "rds-connections-high"
  metric_name         = "DatabaseConnections"
  namespace           = "AWS/RDS"
  statistic           = "Average"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  period              = 300
  threshold           = 100
  alarm_description   = "High number of DB connections"
  alarm_actions       = [aws_sns_topic.alerts.arn]
  dimensions = {
    DBInstanceIdentifier = module.rds.db_instance_identifier
  }
}

# Log group for application logs (ensure retention)
resource "aws_cloudwatch_log_group" "app_logs" {
  name              = "/${var.project}/app"
  retention_in_days = 90
  tags = merge(var.tags, { Environment = var.env })
}

# Use existing Secrets Manager secret if provided (do not create secrets via Terraform)
data "aws_secretsmanager_secret_version" "db_version" {
  secret_id = var.db_secret_arn
}

# Monitoring: SNS topic and CloudWatch alarms
resource "aws_sns_topic" "alerts" {
  name = "${var.project}-alerts"
}

resource "aws_cloudwatch_log_group" "app_logs" {
  name = "/${var.project}/app"
  retention_in_days = 14
}

resource "aws_cloudwatch_metric_alarm" "ec2_company_cpu" {
  alarm_name = "${var.project}-company-ec2-high-cpu"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods = 2
  metric_name = "CPUUtilization"
  namespace = "AWS/EC2"
  period = 300
  statistic = "Average"
  threshold = 80
  alarm_actions = [aws_sns_topic.alerts.arn]
  dimensions = { InstanceId = module.ec2_company.instance_id }
}

resource "aws_cloudwatch_metric_alarm" "rds_connections" {
  alarm_name = "${var.project}-rds-connections"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods = 1
  metric_name = "DatabaseConnections"
  namespace = "AWS/RDS"
  period = 300
  statistic = "Average"
  threshold = 80
  alarm_actions = [aws_sns_topic.alerts.arn]
  dimensions = { DBInstanceIdentifier = module.rds.instance_id }
}
