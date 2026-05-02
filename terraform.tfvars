project_name = "payroll-platform"

aws_region = "ap-south-1"

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

tenant_names = [
  "companies",
  "bureaus",
  "employees"
]

instance_type = "t3.micro"

bucket_name = "payroll-documents"

db_username = "payroll_admin"
db_name     = "payrolldb"
