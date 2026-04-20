terraform {
  backend "s3" {
    bucket         = "otms-dev-state7864582"
    key            = "env/dev/application/otms/frontend-sg/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "terraform-lock"
  }
}

provider "aws" {
  region = var.region
}

# 🔹 VPC Remote State
data "terraform_remote_state" "vpc" {
  backend = "s3"

  config = {
    bucket = "otms-dev-state"
    key    = "env/dev/application/network/vpc/terraform.tfstate"
    region = "us-east-1"
  }
}

# 🔹 Get External ALB SG
data "terraform_remote_state" "alb_sg" {
  backend = "s3"

  config = {
    bucket = "otms-dev-state"
    key    = "env/dev/application/otms/external-alb/terraform.tfstate"
    region = "us-east-1"
  }
}

# 🔹 Frontend Security Group
resource "aws_security_group" "frontend_sg" {
  name        = "${var.project}-${var.env}-frontend-sg"
  description = "Frontend Security Group"
  vpc_id      = data.terraform_remote_state.vpc.outputs.vpc_id

  # ✅ PORT 3000 (from ALB)
  ingress {
    from_port                = 3000
    to_port                  = 3000
    protocol                 = "tcp"
    source_security_group_id = data.terraform_remote_state.alb_sg.outputs.security_group_id
  }

  # ✅ SSH
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # ✅ OUTBOUND
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "${var.project}-${var.env}-frontend-sg"
    Environment = var.env
    Project     = var.project
  }
}
