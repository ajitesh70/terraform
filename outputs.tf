output "key_name" {
  description = "Name of the SSH Key Pair"
  value       = aws_key_pair.generated_key.key_name
}
 
output "private_key_file" {
  description = "Local path of saved private key PEM"
  value       = local_file.private_key_pem.filename
}
