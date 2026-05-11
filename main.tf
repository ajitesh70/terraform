provider "aws" {
  region = var.region
}

terraform {
  backend "s3" {
    bucket         = "otms-dev-state7864582"
    key            = "env/dev/application/otms/postgres-instance/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "terraform-lock"
  }
}

data "terraform_remote_state" "subnet" {
  backend = "s3"
  config = {
    bucket = "otms-dev-state7864582"
    key    = "env/dev/application/network/subnet/terraform.tfstate"
    region = "us-east-1"
  }
}

data "terraform_remote_state" "ssh_key" {
  backend = "s3"
  config = {
    bucket = "otms-dev-state7864582"
    key    = "env/dev/application/network/sshkey/terraform.tfstate"
    region = "us-east-1"
  }
}

data "terraform_remote_state" "postgres_sg" {
  backend = "s3"
  config = {
    bucket = "otms-dev-state7864582"
    key    = "env/dev/application/otms/postgres-sg/terraform.tfstate"
    region = "us-east-1"
  }
}

resource "aws_instance" "postgres_instance" {
  ami                    = var.ami_id
  instance_type          = var.instance_type
  subnet_id              = data.terraform_remote_state.subnet.outputs.private_subnet_ids[2]
  vpc_security_group_ids = [data.terraform_remote_state.postgres_sg.outputs.postgres_sg_id]
  key_name               = data.terraform_remote_state.ssh_key.outputs.key_name

  root_block_device {
    volume_size = 20
    volume_type = "gp3"
  }

  tags = {
    Name        = "${var.project}-${var.env}-postgres-instance"
    Environment = var.env
    Project     = var.project
    ManagedBy   = "Terraform"
  }
}
