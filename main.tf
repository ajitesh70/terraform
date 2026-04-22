provider "aws" {
  region = var.region
}

terraform {
  backend "s3" {
    bucket         = "otms-dev-state7864582"
    key            = "env/dev/application/otms/backend-asg/terraform.tfstate"
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
# ─────────────────────────────────────────
data "terraform_remote_state" "lt" {
  backend = "s3"
  config = {
    bucket = "otms-dev-state7864582"
    key    = "env/dev/application/otms/backend-launch-template/terraform.tfstate"
    region = "us-east-1"
  }
}

# ─────────────────────────────────────────
# REMOTE STATE — TARGET GROUPS
# ─────────────────────────────────────────
data "terraform_remote_state" "tg" {
  backend = "s3"
  config = {
    bucket = "otms-dev-state7864582"
    key    = "env/dev/application/otms/backend-tg/terraform.tfstate"
    region = "us-east-1"
  }
}

# ─────────────────────────────────────────
# AUTO SCALING GROUP
# ─────────────────────────────────────────
resource "aws_autoscaling_group" "backend_asg" {
  name = "${var.project}-${var.env}-backend-asg"

  min_size         = 1
  max_size         = 3
  desired_capacity = 1

  vpc_zone_identifier = [
    data.terraform_remote_state.subnet.outputs.private_subnet_ids[0],
    data.terraform_remote_state.subnet.outputs.private_subnet_ids[1]
  ]

  launch_template {
    id      = data.terraform_remote_state.lt.outputs.launch_template_id
    version = "$Latest"
  }

  # ✅ Attach ALL existing target groups
  target_group_arns = [
    data.terraform_remote_state.tg.outputs.employee_tg_arn,
    data.terraform_remote_state.tg.outputs.attendance_tg_arn,
    data.terraform_remote_state.tg.outputs.salary_tg_arn,
    data.terraform_remote_state.tg.outputs.notification_tg_arn
  ]

  health_check_type         = "ELB"
  health_check_grace_period = 60

  tag {
    key                 = "Name"
    value               = "${var.project}-${var.env}-backend-instance"
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
}
