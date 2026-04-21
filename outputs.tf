output "launch_template_id" {
  description = "Launch Template ID"
  value       = aws_launch_template.app_template.id
}
 
output "launch_template_latest_version" {
  description = "Latest version number of the Launch Template"
  value       = aws_launch_template.app_template.latest_version
}
