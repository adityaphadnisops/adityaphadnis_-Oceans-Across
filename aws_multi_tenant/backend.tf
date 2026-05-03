/*
  Backend configuration example.
  Replace the placeholder values with your real remote state bucket and DynamoDB table.
  Do NOT commit sensitive backend configuration with credentials.

  To enable backend, move these values into a local-only file or configure via CI.
*/

terraform {
  backend "s3" {
    bucket         = "<your-terraform-state-bucket>"
    key            = "<path>/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "<your-lock-table>"
    encrypt        = true
  }
}
