output "backend_sg_id" {
  description = "Backend Security Group ID"
  value       = aws_security_group.backend_sg.id
}

output "backend_sg_name" {
  description = "Backend Security Group Name"
  value       = aws_security_group.backend_sg.name
}

# Alias — consistent naming across modules
output "security_group_id" {
  description = "Alias — Backend Security Group ID"
  value       = aws_security_group.backend_sg.id
}
