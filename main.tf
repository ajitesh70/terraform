provider "aws" {
  region = "us-east-1"
}
 
terraform {
  backend "s3" {
    bucket         = "otms-dev-state7864582"
    key            = "env/dev/application/network/subnet/terraform.tfstate"
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
 
locals {
  az_a = "us-east-1a"
  az_b = "us-east-1b"
}
 
# PUBLIC SUBNET — 1a (Bastion / ALB)
resource "aws_subnet" "public_subnet_1a" {
  vpc_id                  = data.terraform_remote_state.vpc.outputs.vpc_id
  cidr_block              = var.public_subnet_cidr
  availability_zone       = local.az_a
  map_public_ip_on_launch = true
 
  tags = {
    Name        = "otms-dev-public-subnet-1a"
    Environment = "dev"
    Project     = "OTMS"
    ManagedBy   = "Terraform"
  }
}
 
# PUBLIC SUBNET — 1b
resource "aws_subnet" "public_subnet_1b" {
  vpc_id                  = data.terraform_remote_state.vpc.outputs.vpc_id
  cidr_block              = var.public_subnet_2_cidr
  availability_zone       = local.az_b
  map_public_ip_on_launch = true
 
  tags = {
    Name        = "otms-dev-public-subnet-1b"
    Environment = "dev"
    Project     = "OTMS"
    ManagedBy   = "Terraform"
  }
}
 
# PRIVATE SUBNET 1 — Frontend
resource "aws_subnet" "private_subnet_1" {
  vpc_id            = data.terraform_remote_state.vpc.outputs.vpc_id
  cidr_block        = var.private_subnet_1_cidr
  availability_zone = local.az_a
 
  tags = {
    Name        = "otms-dev-private-subnet-frontend"
    Environment = "dev"
    Project     = "OTMS"
    ManagedBy   = "Terraform"
  }
}
 
# PRIVATE SUBNET 2 — Backend
resource "aws_subnet" "private_subnet_2" {
  vpc_id            = data.terraform_remote_state.vpc.outputs.vpc_id
  cidr_block        = var.private_subnet_2_cidr
  availability_zone = local.az_a
 
  tags = {
    Name        = "otms-dev-private-subnet-backend"
    Environment = "dev"
    Project     = "OTMS"
    ManagedBy   = "Terraform"
  }
}
 
# PRIVATE SUBNET 3 — Database
resource "aws_subnet" "private_subnet_3" {
  vpc_id            = data.terraform_remote_state.vpc.outputs.vpc_id
  cidr_block        = var.private_subnet_3_cidr
  availability_zone = local.az_a
 
  tags = {
    Name        = "otms-dev-private-subnet-db"
    Environment = "dev"
    Project     = "OTMS"
    ManagedBy   = "Terraform"
  }
}
