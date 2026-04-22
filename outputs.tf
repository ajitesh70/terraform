output "attendance_sg_id" {
  description = "Attendance Security Group ID"
  value       = aws_security_group.attendance_sg.id
}

output "attendance_sg_name" {
  description = "Attendance Security Group Name"
  value       = aws_security_group.attendance_sg.name
}

output "security_group_id" {
  description = "Alias — Attendance Security Group ID"
  value       = aws_security_group.attendance_sg.id
}
