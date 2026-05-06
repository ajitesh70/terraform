provider "aws" {
  region = var.region
}

terraform {
  backend "s3" {
    bucket         = "otms-dev-state7864582"
    key            = "env/dev/application/otms/backend-sg/terraform.tfstate"
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
# Source for all inbound rules
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
# SECURITY GROUP — Backend (All 4 APIs)
# Inbound  : port 8080 — Employee API
# Inbound  : port 8081 — Attendance API
# Inbound  : port 8082 — Salary API
# Inbound  : port 5000 — Notification API
# Inbound  : port 22   — SSH
# Outbound : all allowed
# ─────────────────────────────────────────
resource "aws_security_group" "backend_sg" {
  name        = "${var.project}-${var.env}-backend-sg"
  description = "Security Group for Backend — allows ports 8080, 8081, 8082, 5000 from External ALB"
  vpc_id      = data.terraform_remote_state.vpc.outputs.vpc_id

  # Employee API — port 8080
  ingress {
    from_port                = 8080
    to_port                  = 8080
    protocol                 = "tcp"
    security_groups = [data.terraform_remote_state.alb_sg.outputs.security_group_id]
    description              = "Allow Employee API traffic from External ALB on port 8080"
  }

  # Attendance API — port 8081
  ingress {
    from_port                = 8081
    to_port                  = 8081
    protocol                 = "tcp"
    security_groups = [data.terraform_remote_state.alb_sg.outputs.security_group_id]
    description              = "Allow Attendance API traffic from External ALB on port 8081"
  }

  # Salary API — port 8082
  ingress {
    from_port                = 8082
    to_port                  = 8082
    protocol                 = "tcp"
    security_groups = [data.terraform_remote_state.alb_sg.outputs.security_group_id]
    description              = "Allow Salary API traffic from External ALB on port 8082"
  }

  # Notification API — port 5000
  ingress {
    from_port                = 5000
    to_port                  = 5000
    protocol                 = "tcp"
    security_groups = [data.terraform_remote_state.alb_sg.outputs.security_group_id]
    description              = "Allow Notification API traffic from External ALB on port 5000"
  }

  # SSH
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
    Name        = "${var.project}-${var.env}-backend-sg"
    Environment = var.env
    Project     = var.project
    ManagedBy   = "Terraform"
  }
}
