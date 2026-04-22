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
# REMOTE STATE — BACKEND SG (NEW)
# ─────────────────────────────────────────
data "terraform_remote_state" "backend_sg" {
  backend = "s3"
  config = {
    bucket = "otms-dev-state7864582"
    key    = "env/dev/application/otms/backend-sg/terraform.tfstate"
    region = "us-east-1"
  }
}

# ─────────────────────────────────────────
# REMOTE STATE — SSH KEY
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
# EC2 INSTANCE — ALL APIs (Single Instance)
# ─────────────────────────────────────────
resource "aws_instance" "backend_instance" {
  ami           = var.ami_id
  instance_type = var.instance_type

  # private-subnet-2
  subnet_id = data.terraform_remote_state.subnet.outputs.private_subnet_ids[1]

  # ✅ ONLY ONE SG (backend-sg)
  vpc_security_group_ids = [
    data.terraform_remote_state.backend_sg.outputs.backend_sg_id
  ]

  key_name                    = data.terraform_remote_state.ssh_key.outputs.key_name
  associate_public_ip_address = false

  tags = {
    Name        = "${var.project}-${var.env}-backend-instance"
    Environment = var.env
    Project     = var.project
    ManagedBy   = "Terraform"
  }
}
