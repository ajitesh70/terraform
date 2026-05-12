provider "aws" {
  region = var.region
}

terraform {
  backend "s3" {
    bucket         = "otms-dev-state7864582"
    key            = "env/dev/application/otms/redis-sg/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "terraform-lock"
  }
}

data "terraform_remote_state" "vpc" {
  backend = "s3"
  config = {
    bucket = "otms-dev-state7864582"
    key    = "env/dev/application/network/vpc/terraform.tfstate"
    region = "us-east-1"
  }
}

resource "aws_security_group" "redis_sg" {
  name        = "${var.project}-${var.env}-redis-sg"
  description = "Security Group for Redis - allows port 6379 from VPC"
  vpc_id      = data.terraform_remote_state.vpc.outputs.vpc_id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "SSH access"
  }

  ingress {
    from_port   = 6379
    to_port     = 6379
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/24"]
    description = "Redis access from VPC"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow all outbound traffic"
  }

  tags = {
    Name        = "${var.project}-${var.env}-redis-sg"
    Environment = var.env
    Project     = var.project
    ManagedBy   = "Terraform"
  }
}
