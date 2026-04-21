provider "aws" {
  region = var.region
}

terraform {
  backend "s3" {
    bucket         = "otms-dev-state7864582"
    key            = "env/dev/application/otms/notification-ec2/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "terraform-lock"
  }
}

# ─────────────────────────────────────────
# REMOTE STATE — SUBNET
# private_subnet_ids[1] = private-subnet-2
# (us-east-1a)
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
# PRIVATE EC2 INSTANCE — Notification
# AMI     : ami-0b73ce37f347c345b
# Type    : t3.small
# Subnet  : private-subnet-2 (us-east-1a)
# SG      : notification-sg (port 5000)
# Key     : otms-dev-key (Mukesh-SSH)
# Public IP : No
# ─────────────────────────────────────────
resource "aws_instance" "notification_instance" {
  ami           = var.ami_id
  instance_type = var.instance_type

  # private-subnet-2 → index [1] in private_subnet_ids list
  subnet_id = data.terraform_remote_state.subnet.outputs.private_subnet_ids[1]

  # Notification SG
  vpc_security_group_ids = [
    data.terraform_remote_state.notification_sg.outputs.notification_sg_id
  ]

  # Mukesh-SSH key pair
  key_name = data.terraform_remote_state.ssh_key.outputs.key_name

  # No Public IP — private server
  associate_public_ip_address = false

  tags = {
    Name        = "${var.project}-${var.env}-notification-instance"
    Environment = var.env
    Project     = var.project
    ManagedBy   = "Terraform"
  }
}
