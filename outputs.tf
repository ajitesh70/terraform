output "employee_rule_arn" {
  value = aws_lb_listener_rule.employee_rule.arn
}

output "attendance_rule_arn" {
  value = aws_lb_listener_rule.attendance_rule.arn
}

output "salary_rule_arn" {
  value = aws_lb_listener_rule.salary_rule.arn
}

output "notification_rule_arn" {
  value = aws_lb_listener_rule.notification_rule.arn
}
