output "employee_tg_arn" {
  value = aws_lb_target_group.employee_tg.arn
}

output "attendance_tg_arn" {
  value = aws_lb_target_group.attendance_tg.arn
}

output "salary_tg_arn" {
  value = aws_lb_target_group.salary_tg.arn
}

output "notification_tg_arn" {
  value = aws_lb_target_group.notification_tg.arn
}
