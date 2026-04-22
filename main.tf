provider "aws" {
  region = var.region
}

terraform {
  backend "s3" {
    bucket         = "otms-dev-state7864582"
    key            = "env/dev/application/otms/listener-rules/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "terraform-lock"
  }
}

# ─────────────────────────────────────────
# REMOTE STATE — LISTENER
# ─────────────────────────────────────────
data "terraform_remote_state" "listener" {
  backend = "s3"
  config = {
    bucket = "otms-dev-state7864582"
    key    = "env/dev/application/otms/listener/terraform.tfstate"
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

# ==========================================================
# EMPLOYEE RULE (Priority 1)
# ==========================================================
resource "aws_lb_listener_rule" "employee_rule" {
  listener_arn = data.terraform_remote_state.listener.outputs.https_listener_arn
  priority     = 1

  action {
    type             = "forward"
    target_group_arn = data.terraform_remote_state.tg.outputs.employee_tg_arn
  }

  condition {
    path_pattern {
      values = ["/api/v1/employee/*"]
    }
  }
}

# ==========================================================
# ATTENDANCE RULE (Priority 2)
# ==========================================================
resource "aws_lb_listener_rule" "attendance_rule" {
  listener_arn = data.terraform_remote_state.listener.outputs.https_listener_arn
  priority     = 2

  action {
    type             = "forward"
    target_group_arn = data.terraform_remote_state.tg.outputs.attendance_tg_arn
  }

  condition {
    path_pattern {
      values = ["/api/v1/attendance/*"]
    }
  }
}

# ==========================================================
# SALARY RULE (Priority 3)
# ==========================================================
resource "aws_lb_listener_rule" "salary_rule" {
  listener_arn = data.terraform_remote_state.listener.outputs.https_listener_arn
  priority     = 3

  action {
    type             = "forward"
    target_group_arn = data.terraform_remote_state.tg.outputs.salary_tg_arn
  }

  condition {
    path_pattern {
      values = ["/api/v1/salary/*"]
    }
  }
}

# ==========================================================
# NOTIFICATION RULE (Priority 4)
# ==========================================================
resource "aws_lb_listener_rule" "notification_rule" {
  listener_arn = data.terraform_remote_state.listener.outputs.https_listener_arn
  priority     = 4

  action {
    type             = "forward"
    target_group_arn = data.terraform_remote_state.tg.outputs.notification_tg_arn
  }

  condition {
    path_pattern {
      values = ["/api/v1/notification/*"]
    }
  }
}
