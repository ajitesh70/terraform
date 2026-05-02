provider "aws" {
  region = var.region
}

terraform {
  backend "s3" {
    bucket         = "otms-dev-state7864582"
    key            = "env/dev/application/otms/asg/terraform.tfstate"
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
# REMOTE STATE — LAUNCH TEMPLATE
# (Suraj-Launch_template branch)
# ─────────────────────────────────────────
data "terraform_remote_state" "launch_template" {
  backend = "s3"

  config = {
    bucket = "otms-dev-state7864582"
    key    = "env/dev/application/otms/ec2-template/terraform.tfstate"
    region = "us-east-1"
  }
}

# ─────────────────────────────────────────
# REMOTE STATE — FRONTEND TARGET GROUP
# ─────────────────────────────────────────
data "terraform_remote_state" "target_group" {
  backend = "s3"

  config = {
    bucket = "otms-dev-state7864582"
    key    = "env/dev/application/otms/target-group/terraform.tfstate"
    region = "us-east-1"
  }
}

# ─────────────────────────────────────────
# AUTO SCALING GROUP
# ─────────────────────────────────────────
resource "aws_autoscaling_group" "frontend_asg" {
  name = "${var.project}-${var.env}-frontend-asg"

  # Capacity
  min_size         = var.min_size
  max_size         = var.max_size
  desired_capacity = var.desired_capacity

  # Place instances in private subnets
  vpc_zone_identifier = data.terraform_remote_state.subnet.outputs.private_subnet_ids

  # Attach to frontend target group
  target_group_arns = [
    data.terraform_remote_state.target_group.outputs.frontend_tg_arn
  ]

  # Health check via ALB
  health_check_type = "EC2"
  health_check_grace_period = 60

  # Use Launch Template
  launch_template {
    id      = data.terraform_remote_state.launch_template.outputs.launch_template_id
    version = data.terraform_remote_state.launch_template.outputs.launch_template_latest_version
  }

  # Instance refresh on launch template update
  instance_refresh {
    strategy = "Rolling"
    preferences {
      min_healthy_percentage = 50
    }
  }

  tag {
    key                 = "Name"
    value               = "${var.project}-${var.env}-frontend-asg-instance"
    propagate_at_launch = true
  }

  tag {
    key                 = "Environment"
    value               = var.env
    propagate_at_launch = true
  }

  tag {
    key                 = "Project"
    value               = var.project
    propagate_at_launch = true
  }

  tag {
    key                 = "ManagedBy"
    value               = "Terraform"
    propagate_at_launch = true
  }
}
