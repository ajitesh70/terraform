provider "aws" {
  region = var.region
}

terraform {
  backend "s3" {
    bucket         = "otms-dev-state7864582"
    key            = "env/dev/application/otms/tg-notification/terraform.tfstate"
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
# REMOTE STATE — NOTIFICATION EC2 INSTANCE
# (5000 port wala — Gunjan ka instance)
# ─────────────────────────────────────────
data "terraform_remote_state" "notification_instance" {
  backend = "s3"

  config = {
    bucket = "otms-dev-state7864582"
    key    = "env/dev/application/otms/notification-ec2/terraform.tfstate"
    region = "us-east-1"
  }
}

# ─────────────────────────────────────────
# TARGET GROUP — notification-tg
# Type     : Instance
# Protocol : HTTP
# Port     : 5000
# ─────────────────────────────────────────
resource "aws_lb_target_group" "notification_tg" {
  name        = "notification-tg"
  port        = 5000
  protocol    = "HTTP"
  vpc_id      = data.terraform_remote_state.vpc.outputs.vpc_id
  target_type = "instance"

  # Health Check on port 5000
  health_check {
    enabled             = true
    path                = var.health_check_path
    port                = "5000"
    protocol            = "HTTP"
    healthy_threshold   = 3
    unhealthy_threshold = 3
    timeout             = 5
    interval            = 30
    matcher             = "200"
  }

  tags = {
    Name        = "notification-tg"
    Environment = var.env
    Project     = var.project
    ManagedBy   = "Terraform"
  }
}

# ─────────────────────────────────────────
# TARGET GROUP ATTACHMENT
# Notification EC2 instance on port 5000
# Instance ID fetched from notification-ec2
# remote state
# ─────────────────────────────────────────
resource "aws_lb_target_group_attachment" "notification_attachment" {
  target_group_arn = aws_lb_target_group.notification_tg.arn
  target_id        = data.terraform_remote_state.notification_instance.outputs.instance_id
  port             = 5000
}
