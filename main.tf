provider "aws" {
  region = var.region
}
 
terraform {
  backend "s3" {
    bucket         = "otms-dev-state7864582"
    key            = "env/dev/application/otms/ec2-template/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "terraform-lock"
  }
}
 
# GET SUBNET FROM REMOTE STATE
data "terraform_remote_state" "subnet" {
  backend = "s3"
 
  config = {
    bucket = "otms-dev-state7864582"
    key    = "env/dev/application/network/subnet/terraform.tfstate"
    region = "us-east-1"
  }
}
 
# GET EXTERNAL ALB SG FROM REMOTE STATE
data "terraform_remote_state" "alb_sg" {
  backend = "s3"
 
  config = {
    bucket = "otms-dev-state7864582"
    key    = "env/dev/application/otms/external-alb/terraform.tfstate"
    region = "us-east-1"
  }
}
 
# Launch Template
resource "aws_launch_template" "app_template" {
  name_prefix   = "${var.project}-${var.env}-template-"
  image_id      = var.ami_id
  instance_type = var.instance_type
 
  # SSH Key attached
  key_name = var.key_name
 
  vpc_security_group_ids = [
    data.terraform_remote_state.alb_sg.outputs.security_group_id
  ]
 
  monitoring {
    enabled = true
  }
 
  tag_specifications {
    resource_type = "instance"
 
    tags = {
      Name        = "${var.project}-${var.env}-app"
      Environment = var.env
      Project     = var.project
      ManagedBy   = "Terraform"
    }
  }
}
