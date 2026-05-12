output "redis_instance_id" {
  value = aws_instance.redis_instance.id
}

output "redis_private_ip" {
  value = aws_instance.redis_instance.private_ip
}
