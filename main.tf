provider "aws" {
  region = var.region
}

terraform {
  backend "s3" {
    bucket         = "otms-dev-state7864582"
    key            = "env/dev/application/otms/target-group/terraform.tfstate"
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
# REMOTE STATE — FRONTEND EC2 INSTANCE
# ─────────────────────────────────────────
data "terraform_remote_state" "frontend_instance" {
  backend = "s3"

  config = {
    bucket = "otms-dev-state7864582"
    key    = "env/dev/application/otms/frontend-ec2/terraform.tfstate"
    region = "us-east-1"
  }
}

# ─────────────────────────────────────────
# TARGET GROUP — Frontend (Port 3000)
# ─────────────────────────────────────────
resource "aws_lb_target_group" "frontend_tg" {
  name        = "${var.project}-${var.env}-frontend-tg"
  port        = 3000
  protocol    = "HTTP"
  vpc_id      = data.terraform_remote_state.vpc.outputs.vpc_id
  target_type = "instance"

  # Health Check on port 3000
  health_check {
    enabled             = true
    path                = var.health_check_path
    port                = "3000"
    protocol            = "HTTP"
    healthy_threshold   = 3
    unhealthy_threshold = 3
    timeout             = 5
    interval            = 30
    matcher             = "200"
  }

  tags = {
    Name        = "${var.project}-${var.env}-frontend-tg"
    Environment = var.env
    Project     = var.project
    ManagedBy   = "Terraform"
  }
}

# ─────────────────────────────────────────
# TARGET GROUP ATTACHMENT — Frontend EC2
# Registers the private instance on port 3000
# ─────────────────────────────────────────
resource "aws_lb_target_group_attachment" "frontend_attachment" {
  target_group_arn = aws_lb_target_group.frontend_tg.arn
  target_id        = data.terraform_remote_state.frontend_instance.outputs.instance_id
  port             = 3000
}
