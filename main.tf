provider "aws" {
  region = var.region
}

terraform {
  backend "s3" {
    bucket = "otms-dev-state7864582"
    key    = "env/dev/application/otms/external-alb/terraform.tfstate"
    region = "us-east-1"
    dynamodb_table = "terraform-lock"
  }
}

#  Remote State: VPC
data "terraform_remote_state" "vpc" {
  backend = "s3"

  config = {
    bucket = "otms-dev-state7864582"
    key    = "env/dev/application/network/vpc/terraform.tfstate"
    region = "us-east-1"
  }
}

#  Security Group
resource "aws_security_group" "sg" {
  name        = "${var.project}-${var.env}-security-group"
  description = "Security group for OTMS"
  vpc_id      = data.terraform_remote_state.vpc.outputs.vpc_id

  # Inbound Rule 1 (All TCP)
  ingress {
    description = "Allow all TCP"
    from_port   = 0
    to_port     = 65535
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  #  Inbound Rule 2 (HTTP)
  ingress {
    description = "Allow HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  #  Outbound (default allow all)
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "${var.project}-${var.env}-security-group"
    Environment = var.env
    Project     = var.project
  }
}
