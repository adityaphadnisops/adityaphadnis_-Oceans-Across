output "bucket_name" {
  description = "Name of the payroll documents S3 bucket"
  value       = aws_s3_bucket.payroll_documents.bucket
}

output "bucket_arn" {
  description = "ARN of the payroll documents S3 bucket"
  value       = aws_s3_bucket.payroll_documents.arn
}
