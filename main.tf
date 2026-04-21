provider "aws" {
  region = var.region
}

terraform {
  backend "s3" {
    bucket         = "otms-dev-state7864582"
    key            = "env/dev/application/otms/notification-sg/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "terraform-lock"
  }
}

# ─────────────────────────────────────────
# REMOTE STATE — VPC
# ─────────────────────────────────────────
data "terraform_remote_state" "vpc" {
  backend = "s3"

  config = {
    bucket = "otms-dev-state7864582"
    key    = "env/dev/application/network/vpc/terraform.tfstate"
    region = "us-east-1"
  }
}

# ─────────────────────────────────────────
# REMOTE STATE — EXTERNAL ALB SG
# Source for inbound rule on port 5000
# ─────────────────────────────────────────
data "terraform_remote_state" "alb_sg" {
  backend = "s3"

  config = {
    bucket = "otms-dev-state7864582"
    key    = "env/dev/application/otms/external-alb/terraform.tfstate"
    region = "us-east-1"
  }
}

# ─────────────────────────────────────────
# SECURITY GROUP — Notification Service
# Inbound  : port 5000 from External ALB SG
# Inbound  : port 22   SSH
# Outbound : all allowed
# ─────────────────────────────────────────
resource "aws_security_group" "notification_sg" {
  name        = "${var.project}-${var.env}-notification-sg"
  description = "Security Group for Notification Service — allows port 5000 from External ALB"
  vpc_id      = data.terraform_remote_state.vpc.outputs.vpc_id

  # Allow port 5000 from External ALB SG only
  ingress {
    from_port                = 5000
    to_port                  = 5000
    protocol                 = "tcp"
    source_security_group_id = data.terraform_remote_state.alb_sg.outputs.security_group_id
    description              = "Allow traffic from External ALB on port 5000"
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
    Name        = "${var.project}-${var.env}-notification-sg"
    Environment = var.env
    Project     = var.project
    ManagedBy   = "Terraform"
  }
}
