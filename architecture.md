# Payroll Infrastructure Architecture

This Terraform project creates the following AWS resources for the payroll platform:

- VPC with public and private subnets across at least two availability zones
- NAT Gateway for outbound access from private subnets
- Three isolated EC2 instances, one per tenant type: Companies, Bureaus, Employees
- RDS PostgreSQL database in a private subnet
- Versioned S3 bucket for payroll documents and reports
- IAM roles scoped per tenant for tenant-specific resource access
- Security Groups and NACLs to isolate traffic between tenant environments

## Architecture Diagram

```mermaid
flowchart LR
  A[VPC] --> B[Public Subnets]
  A --> C[Private Subnets]
  B --> IGW[Internet Gateway]
  B --> NAT[NAT Gateway]
  C --> EC2C[Companies Backend EC2]
  C --> EC2B[Bureaus Backend EC2]
  C --> EC2E[Employees Backend EC2]
  C --> RDS[RDS PostgreSQL]
  A --> S3[Payroll Documents S3 Bucket]
  EC2C -->|S3 access| S3
  EC2B -->|S3 access| S3
  EC2E -->|S3 access| S3
  EC2C -->|DB access| RDS
  EC2B -->|DB access| RDS
  EC2E -->|DB access| RDS
  subgraph IAM
    IR[Companies IAM Role]
    IB[Bureaus IAM Role]
    IE[Employees IAM Role]
  end
  IR --> EC2C
  IB --> EC2B
  IE --> EC2E
```
