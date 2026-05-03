data "aws_kms_alias" "s3" {
  name = "alias/aws/s3"
}

module "vpc" {
  source = "./modules/vpc"

  project_name         = var.project_name
  vpc_cidr             = var.vpc_cidr
  public_subnet_cidrs  = var.public_subnet_cidrs
  private_subnet_cidrs = var.private_subnet_cidrs
  availability_zones   = var.availability_zones
}



# 🔐 IAM (must output role_arns)
module "iam" {
  source = "./modules/iam"

  tenant_names = var.tenant_names
  bucket_name  = var.bucket_name

  db_secret_arn = module.database.db_secret_arn
}

# 💻 EC2 (tenants)
module "tenants" {
  source = "./modules/tenants"

  project_name           = var.project_name
  vpc_id                 = module.vpc.vpc_id
  private_subnet_ids     = module.vpc.private_subnet_ids
  tenant_names           = var.tenant_names
  instance_type          = var.instance_type
  instance_profile_names = module.iam.instance_profile_names
}

# 🪣 STORAGE (FIXED - ALL REQUIRED ARGS PASSED)
module "storage" {
  source = "./modules/storage"

  bucket_name      = var.bucket_name
  kms_key_id = data.aws_kms_alias.s3.target_key_id
  tenants          = var.tenant_names
  tenant_role_arns = module.iam.role_arns

  tags = {
    Project     = var.project_name
    Environment = "dev"
  }
}

# 🗄️ DATABASE
module "database" {
  source = "./modules/database"

  project_name               = var.project_name
  vpc_id                     = module.vpc.vpc_id
  private_subnet_ids         = module.vpc.private_subnet_ids
  allowed_security_group_ids = module.tenants.tenant_security_group_ids
  db_username                = var.db_username
  db_name                    = var.db_name
}