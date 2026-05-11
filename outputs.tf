output "postgres_instance_id" {
  value = aws_instance.postgres_instance.id
}

output "postgres_private_ip" {
  value = aws_instance.postgres_instance.private_ip
}
