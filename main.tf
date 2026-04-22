provider "aws" {
  region = var.region
}

terraform {
  backend "s3" {
    bucket         = "otms-dev-state7864582"
    key            = "env/dev/application/otms/backend-tg/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "terraform-lock"
  }
}

# ─────────────────────────────────────────
# REMOTE STATE — VPC
# ─────────────────────────────────────────
data "terraform_remote_state" "vpc" {
  backend = "s3"
  config = {
    bucket = "otms-dev-state7864582"
    key    = "env/dev/application/network/vpc/terraform.tfstate"
    region = "us-east-1"
  }
}

# ─────────────────────────────────────────
# REMOTE STATE — BACKEND EC2
# ─────────────────────────────────────────
data "terraform_remote_state" "ec2" {
  backend = "s3"
  config = {
    bucket = "otms-dev-state7864582"
    key    = "env/dev/application/otms/notification-ec2/terraform.tfstate"
    region = "us-east-1"
  }
}

# ==========================================================
# 1. EMPLOYEE TG — PORT 8080
# ==========================================================
resource "aws_lb_target_group" "employee_tg" {
  name     = "${var.project}-${var.env}-tg-employee"
  port     = 8080
  protocol = "HTTP"
  vpc_id   = data.terraform_remote_state.vpc.outputs.vpc_id
  target_type = "instance"

  health_check {
    path                = "/"
    port                = "8080"
    protocol            = "HTTP"
    matcher             = "200"
    interval            = 30
  }

  tags = {
    Name        = "tg-employee"
    Environment = var.env
    Project     = var.project
  }
}

resource "aws_lb_target_group_attachment" "employee_attach" {
  target_group_arn = aws_lb_target_group.employee_tg.arn
  target_id        = data.terraform_remote_state.ec2.outputs.instance_id
  port             = 8080
}

# ==========================================================
# 2. ATTENDANCE TG — PORT 8081
# ==========================================================
resource "aws_lb_target_group" "attendance_tg" {
  name     = "${var.project}-${var.env}-tg-attendance"
  port     = 8081
  protocol = "HTTP"
  vpc_id   = data.terraform_remote_state.vpc.outputs.vpc_id
  target_type = "instance"

  health_check {
    path     = "/"
    port     = "8081"
    protocol = "HTTP"
    matcher  = "200"
  }

  tags = {
    Name        = "tg-attendance"
    Environment = var.env
    Project     = var.project
  }
}

resource "aws_lb_target_group_attachment" "attendance_attach" {
  target_group_arn = aws_lb_target_group.attendance_tg.arn
  target_id        = data.terraform_remote_state.ec2.outputs.instance_id
  port             = 8081
}

# ==========================================================
# 3. SALARY TG — PORT 8082
# ==========================================================
resource "aws_lb_target_group" "salary_tg" {
  name     = "${var.project}-${var.env}-tg-salary"
  port     = 8082
  protocol = "HTTP"
  vpc_id   = data.terraform_remote_state.vpc.outputs.vpc_id
  target_type = "instance"

  health_check {
    path     = "/"
    port     = "8082"
    protocol = "HTTP"
    matcher  = "200"
  }

  tags = {
    Name        = "tg-salary"
    Environment = var.env
    Project     = var.project
  }
}

resource "aws_lb_target_group_attachment" "salary_attach" {
  target_group_arn = aws_lb_target_group.salary_tg.arn
  target_id        = data.terraform_remote_state.ec2.outputs.instance_id
  port             = 8082
}

# ==========================================================
# 4. NOTIFICATION TG — PORT 5000
# ==========================================================
resource "aws_lb_target_group" "notification_tg" {
  name     = "${var.project}-${var.env}-tg-notification"
  port     = 5000
  protocol = "HTTP"
  vpc_id   = data.terraform_remote_state.vpc.outputs.vpc_id
  target_type = "instance"

  health_check {
    path     = "/"
    port     = "5000"
    protocol = "HTTP"
    matcher  = "200"
  }

  tags = {
    Name        = "tg-notification"
    Environment = var.env
    Project     = var.project
  }
}

resource "aws_lb_target_group_attachment" "notification_attach" {
  target_group_arn = aws_lb_target_group.notification_tg.arn
  target_id        = data.terraform_remote_state.ec2.outputs.instance_id
  port             = 5000
}
