output "db_instance_identifier" {
  value = var.create_db ? aws_db_instance.this[0].id : data.aws_db_instance.existing[0].id
}

output "address" {
  value = var.create_db ? aws_db_instance.this[0].address : data.aws_db_instance.existing[0].address
}

output "port" {
  value = var.create_db ? aws_db_instance.this[0].port : data.aws_db_instance.existing[0].port
}
output "endpoint" {
  value = aws_db_instance.this.endpoint
}

output "address" {
  value = aws_db_instance.this.address
}

output "instance_id" {
  value = aws_db_instance.this.id
}
