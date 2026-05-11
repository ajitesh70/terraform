output "frontend_sg_id" {
  description = "Frontend Security Group ID"
  value       = aws_security_group.frontend_sg.id
}
 
output "frontend_sg_name" {
  description = "Frontend Security Group Name"
  value       = aws_security_group.frontend_sg.name
}
 
# Alias for consistency with other modules
output "security_group_id" {
  description = "Alias output — Security Group ID"
  value       = aws_security_group.frontend_sg.id
}
