output "scylla_instance_id" {
  value = aws_instance.scylla_instance.id
}

output "scylla_private_ip" {
  value = aws_instance.scylla_instance.private_ip
}
