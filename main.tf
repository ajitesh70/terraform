provider "aws" {
  region = var.region
}

terraform {
  backend "s3" {
    bucket         = "otms-dev-state7864582"
    key            = "env/dev/application/otms/alb/terraform.tfstate"
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
# REMOTE STATE — SUBNET
# ─────────────────────────────────────────
data "terraform_remote_state" "subnet" {
  backend = "s3"

  config = {
    bucket = "otms-dev-state7864582"
    key    = "env/dev/application/network/subnet/terraform.tfstate"
    region = "us-east-1"
  }
}

# ─────────────────────────────────────────
# REMOTE STATE — EXTERNAL ALB SG
# (Created in external-alb-sg branch)
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
# APPLICATION LOAD BALANCER (External)
# ─────────────────────────────────────────
resource "aws_lb" "alb" {
  name               = "${var.project}-${var.env}-external-alb"
  internal           = false
  load_balancer_type = "application"

  # SG fetched from external-alb-sg remote state
  security_groups = [
    data.terraform_remote_state.alb_sg.outputs.security_group_id
  ]

  # Placed in both public subnets
  subnets = data.terraform_remote_state.subnet.outputs.public_subnet_ids

  enable_deletion_protection = false
  idle_timeout               = 60

  tags = {
    Name        = "${var.project}-${var.env}-external-alb"
    Environment = var.env
    Project     = var.project
    ManagedBy   = "Terraform"
  }
}
