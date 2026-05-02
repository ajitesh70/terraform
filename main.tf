provider "aws" {
  region = var.region
}
 
terraform {
  backend "s3" {
    bucket         = "otms-dev-state7864582"
    key            = "env/dev/application/otms/frontend-sg/terraform.tfstate"
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
 
# GET EXTERNAL ALB SG FROM REMOTE STATE
data "terraform_remote_state" "alb_sg" {
  backend = "s3"
 
  config = {
    bucket = "otms-dev-state7864582"
    key    = "env/dev/application/otms/external-alb/terraform.tfstate"
    region = "us-east-1"
  }
}
 
# Frontend Security Group
resource "aws_security_group" "frontend_sg" {
  name        = "${var.project}-${var.env}-frontend-sg"
  description = "Frontend Security Group - allows traffic from ALB on port 3000"
  vpc_id      = data.terraform_remote_state.vpc.outputs.vpc_id
 
  # Allow port 3000 from ALB only
  ingress {
    from_port                = 3000
    to_port                  = 3000
    protocol                 = "tcp"
    security_groups = [data.terraform_remote_state.alb_sg.outputs.security_group_id]
    description              = "Allow traffic from External ALB"
  }
 
  # Allow SSH
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "SSH access"
  }
 
  # Allow all outbound
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow all outbound traffic"
  }
 
  tags = {
    Name        = "${var.project}-${var.env}-frontend-sg"
    Environment = var.env
    Project     = var.project
    ManagedBy   = "Terraform"
  }
}
