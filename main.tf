provider "aws" {
  region = "us-east-1"
}
 
terraform {
  backend "s3" {
    bucket         = "otms-dev-state7864582"
    key            = "env/dev/application/network/IGW/terraform.tfstate"
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
 
resource "aws_internet_gateway" "igw" {
  vpc_id = data.terraform_remote_state.vpc.outputs.vpc_id
 
  tags = {
    Name        = "otms-dev-igw"
    Environment = "dev"
    Project     = "OTMS"
    ManagedBy   = "Terraform"
  }
}
