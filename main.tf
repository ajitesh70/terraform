provider "aws" {
  region = "us-east-1"
}
 
terraform {
  backend "s3" {
    bucket         = "otms-dev-state7864582"
    key            = "env/dev/application/network/vpc/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "terraform-lock"
  }
}
 
resource "aws_vpc" "main_vpc" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true
 
  tags = {
    Name        = var.vpc_name
    Environment = "dev"
    Project     = "OTMS"
    ManagedBy   = "Terraform"
  }
}
