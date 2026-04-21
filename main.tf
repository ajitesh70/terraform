provider "aws" {
  region = "us-east-1"
}
 
terraform {
  backend "s3" {
    bucket         = "otms-dev-state7864582"
    key            = "env/dev/application/network/NAT/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "terraform-lock"
  }
}
 
# GET VPC FROM REMOTE STATE
data "terraform_remote_state" "vpc" {
  backend = "s3"
  config = {
    bucket = "otms-dev-state7864582"
    key    = "env/dev/application/network/vpc/terraform.tfstate"
    region = "us-east-1"
  }
}
 
# GET SUBNET FROM REMOTE STATE
data "terraform_remote_state" "subnet" {
  backend = "s3"
  config = {
    bucket = "otms-dev-state7864582"
    key    = "env/dev/application/network/subnet/terraform.tfstate"
    region = "us-east-1"
  }
}
 
# Elastic IP for NAT
resource "aws_eip" "nat_eip" {
  domain = "vpc"
 
  tags = {
    Name        = "otms-dev-nat-eip"
    Environment = "dev"
    Project     = "OTMS"
    ManagedBy   = "Terraform"
  }
}
 
# NAT Gateway — placed in first public subnet
resource "aws_nat_gateway" "nat_gw" {
  allocation_id = aws_eip.nat_eip.id
  subnet_id     = data.terraform_remote_state.subnet.outputs.public_subnet_ids[0]
 
  tags = {
    Name        = "otms-dev-nat-gateway"
    Environment = "dev"
    Project     = "OTMS"
    ManagedBy   = "Terraform"
  }
}
