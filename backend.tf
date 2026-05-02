terraform {
  backend "s3" {
    bucket         = "my-terraform-state-bucket-rajmodi-2026"
    key            = "eks/terraform.tfstate"
    region         = "ap-south-1"
    dynamodb_table = "terraform-locks"
    encrypt        = true
  }
}
