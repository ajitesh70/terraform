output "instance_id" {
  description = "Backend EC2 Instance ID"
  value       = aws_instance.backend_instance.id
}

output "private_ip" {
  description = "Private IP"
  value       = aws_instance.backend_instance.private_ip
}
