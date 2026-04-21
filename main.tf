provider "aws" {
  region = var.region
}

terraform {
  backend "s3" {
    bucket         = "otms-dev-state7864582"
    key            = "env/dev/application/otms/notification-template/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "terraform-lock"
  }
}

# ─────────────────────────────────────────
# REMOTE STATE — NOTIFICATION SG
# ─────────────────────────────────────────
data "terraform_remote_state" "notification_sg" {
  backend = "s3"

  config = {
    bucket = "otms-dev-state7864582"
    key    = "env/dev/application/otms/notification-sg/terraform.tfstate"
    region = "us-east-1"
  }
}

# ─────────────────────────────────────────
# REMOTE STATE — SSH KEY
# (Mukesh-SSH branch)
# ─────────────────────────────────────────
data "terraform_remote_state" "ssh_key" {
  backend = "s3"

  config = {
    bucket = "otms-dev-state7864582"
    key    = "env/dev/application/network/sshkey/terraform.tfstate"
    region = "us-east-1"
  }
}

# ─────────────────────────────────────────
# LAUNCH TEMPLATE — Notification Service
# AMI     : ami-0b73ce37f347c345b
# Type    : t3.small
# SG      : notification-sg (port 5000)
# Key     : otms-dev-key (Mukesh-SSH)
# Public IP : No
# ─────────────────────────────────────────
resource "aws_launch_template" "notification_template" {
  name_prefix   = "${var.project}-${var.env}-notification-template-"
  image_id      = var.ami_id
  instance_type = var.instance_type

  # Mukesh-SSH key pair
  key_name = data.terraform_remote_state.ssh_key.outputs.key_name

  # Notification SG
  vpc_security_group_ids = [
    data.terraform_remote_state.notification_sg.outputs.notification_sg_id
  ]

  # No Public IP
  network_interfaces {
    associate_public_ip_address = false
    security_groups = [
      data.terraform_remote_state.notification_sg.outputs.notification_sg_id
    ]
  }

  # Detailed monitoring
  monitoring {
    enabled = true
  }

  tag_specifications {
    resource_type = "instance"

    tags = {
      Name        = "${var.project}-${var.env}-notification-app"
      Environment = var.env
      Project     = var.project
      ManagedBy   = "Terraform"
    }
  }

  tags = {
    Name        = "${var.project}-${var.env}-notification-template"
    Environment = var.env
    Project     = var.project
    ManagedBy   = "Terraform"
  }
}
