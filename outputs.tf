output "public_route_table_id" {
  description = "Public route table ID"
  value       = aws_route_table.public_rt.id
}
 
output "private_route_table_id" {
  description = "Private route table ID"
  value       = aws_route_table.private_rt.id
}
