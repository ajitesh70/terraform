provider "aws" {
  region = var.region
}

terraform {
  backend "s3" {
    bucket         = "otms-dev-state7864582"
    key            = "env/dev/application/otms/asg-policies/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "terraform-lock"
  }
}

# ─────────────────────────────────────────
# REMOTE STATE — AUTO SCALING GROUP
# ─────────────────────────────────────────
data "terraform_remote_state" "asg" {
  backend = "s3"

  config = {
    bucket = "otms-dev-state7864582"
    key    = "env/dev/application/otms/asg/terraform.tfstate"
    region = "us-east-1"
  }
}

# ─────────────────────────────────────────
# SCALE OUT POLICY
# Trigger: CPU > 70% → add 1 instance
# ─────────────────────────────────────────
resource "aws_autoscaling_policy" "scale_out" {
  name                   = "${var.project}-${var.env}-scale-out-policy"
  autoscaling_group_name = data.terraform_remote_state.asg.outputs.asg_name
  adjustment_type        = "ChangeInCapacity"
  scaling_adjustment     = 1
  cooldown               = 120
  policy_type            = "SimpleScaling"
}

# ─────────────────────────────────────────
# SCALE IN POLICY
# Trigger: CPU < 30% → remove 1 instance
# ─────────────────────────────────────────
resource "aws_autoscaling_policy" "scale_in" {
  name                   = "${var.project}-${var.env}-scale-in-policy"
  autoscaling_group_name = data.terraform_remote_state.asg.outputs.asg_name
  adjustment_type        = "ChangeInCapacity"
  scaling_adjustment     = -1
  cooldown               = 120
  policy_type            = "SimpleScaling"
}

# ─────────────────────────────────────────
# CLOUDWATCH ALARM — CPU HIGH
# Triggers scale_out policy
# ─────────────────────────────────────────
resource "aws_cloudwatch_metric_alarm" "cpu_high" {
  alarm_name          = "${var.project}-${var.env}-cpu-high"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = 60
  statistic           = "Average"
  threshold           = var.scale_out_cpu_threshold
  alarm_description   = "Scale out when CPU > ${var.scale_out_cpu_threshold}%"

  dimensions = {
    AutoScalingGroupName = data.terraform_remote_state.asg.outputs.asg_name
  }

  alarm_actions = [aws_autoscaling_policy.scale_out.arn]

  tags = {
    Name        = "${var.project}-${var.env}-cpu-high-alarm"
    Environment = var.env
    Project     = var.project
    ManagedBy   = "Terraform"
  }
}

# ─────────────────────────────────────────
# CLOUDWATCH ALARM — CPU LOW
# Triggers scale_in policy
# ─────────────────────────────────────────
resource "aws_cloudwatch_metric_alarm" "cpu_low" {
  alarm_name          = "${var.project}-${var.env}-cpu-low"
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = 2
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = 60
  statistic           = "Average"
  threshold           = var.scale_in_cpu_threshold
  alarm_description   = "Scale in when CPU < ${var.scale_in_cpu_threshold}%"

  dimensions = {
    AutoScalingGroupName = data.terraform_remote_state.asg.outputs.asg_name
  }

  alarm_actions = [aws_autoscaling_policy.scale_in.arn]

  tags = {
    Name        = "${var.project}-${var.env}-cpu-low-alarm"
    Environment = var.env
    Project     = var.project
    ManagedBy   = "Terraform"
  }
}
