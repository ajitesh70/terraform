provider "aws" {
  region = var.region
}

terraform {
  backend "s3" {
    bucket         = "otms-dev-state7864582"
    key            = "env/dev/application/otms/backend-launch-template/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "terraform-lock"
  }
}

data "terraform_remote_state" "backend_sg" {
  backend = "s3"
  config = {
    bucket = "otms-dev-state7864582"
    key    = "env/dev/application/otms/backend-sg/terraform.tfstate"
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

resource "aws_launch_template" "backend_lt" {
  name_prefix   = "${var.project}-${var.env}-backend-lt"
  image_id      = var.ami_id
  instance_type = var.instance_type

  key_name = data.terraform_remote_state.ssh_key.outputs.key_name

  vpc_security_group_ids = [
    data.terraform_remote_state.backend_sg.outputs.backend_sg_id
  ]

  monitoring {
    enabled = true
  }

 

  tag_specifications {
    resource_type = "instance"

    tags = {
      Name        = "${var.project}-${var.env}-backend-instance"
      Environment = var.env
      Project     = var.project
      ManagedBy   = "Terraform"
    }
  }
}
