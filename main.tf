provider "aws" {
  region = var.region
}

terraform {
  backend "s3" {
    bucket         = "otms-dev-state7864582"
    key            = "env/dev/application/otms/backend-asg-policy/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "terraform-lock"
  }
}

# ─────────────────────────────────────────
# REMOTE STATE — ASG
# ─────────────────────────────────────────
data "terraform_remote_state" "asg" {
  backend = "s3"
  config = {
    bucket = "otms-dev-state7864582"
    key    = "env/dev/application/otms/backend-asg/terraform.tfstate"
    region = "us-east-1"
  }
}

# ==========================================================
# SCALE OUT POLICY (Add 1 instance)
# ==========================================================
resource "aws_autoscaling_policy" "scale_out" {
  name                   = "backend-scale-out"
  scaling_adjustment     = 1
  adjustment_type        = "ChangeInCapacity"
  cooldown               = 120
  autoscaling_group_name = data.terraform_remote_state.asg.outputs.asg_name
}

# ==========================================================
# SCALE IN POLICY (Remove 1 instance)
# ==========================================================
resource "aws_autoscaling_policy" "scale_in" {
  name                   = "backend-scale-in"
  scaling_adjustment     = -1
  adjustment_type        = "ChangeInCapacity"
  cooldown               = 120
  autoscaling_group_name = data.terraform_remote_state.asg.outputs.asg_name
}

# ==========================================================
# CLOUDWATCH ALARM — HIGH CPU (>70%)
# ==========================================================
resource "aws_cloudwatch_metric_alarm" "cpu_high" {
  alarm_name          = "backend-cpu-high"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = 60
  statistic           = "Average"
  threshold           = 70

  dimensions = {
    AutoScalingGroupName = data.terraform_remote_state.asg.outputs.asg_name
  }

  alarm_actions = [
    aws_autoscaling_policy.scale_out.arn
  ]
}

# ==========================================================
# CLOUDWATCH ALARM — LOW CPU (<30%)
# ==========================================================
resource "aws_cloudwatch_metric_alarm" "cpu_low" {
  alarm_name          = "backend-cpu-low"
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = 2
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = 60
  statistic           = "Average"
  threshold           = 30

  dimensions = {
    AutoScalingGroupName = data.terraform_remote_state.asg.outputs.asg_name
  }

  alarm_actions = [
    aws_autoscaling_policy.scale_in.arn
  ]
}
