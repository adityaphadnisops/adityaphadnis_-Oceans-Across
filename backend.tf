terraform {
  backend "s3" {
    bucket         = "my-terraform-state-bucket-aditya-2026"
    key            = "payroll/terraform.tfstate"
    region         = "ap-south-1"
    #dynamodb_table = "terraform-locks"
    encrypt        = true
  }
}
