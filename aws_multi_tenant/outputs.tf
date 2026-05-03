output "vpc_id" {
  value = module.vpc.vpc_id
}

output "private_subnets" {
  value = module.vpc.private_subnets
}

output "bucket_arn" {
  value = module.s3.bucket_arn
}

output "rds_endpoint" {
  value = module.rds.address
}
