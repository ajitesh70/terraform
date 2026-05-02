output "instance_id" {
  description = "Frontend EC2 instance ID"
  value       = aws_instance.frontend_instance.id
}

output "private_ip" {
  description = "Frontend EC2 private IP address"
  value       = aws_instance.frontend_instance.private_ip
}

output "instance_arn" {
  description = "Frontend EC2 instance ARN"
  value       = aws_instance.frontend_instance.arn
}
