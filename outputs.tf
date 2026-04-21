# ─────────────────────────────────────────
# ASG Policies Outputs
# ─────────────────────────────────────────
output "scale_out_policy_arn" {
  description = "ARN of the Scale Out policy"
  value       = aws_autoscaling_policy.scale_out.arn
}

output "scale_in_policy_arn" {
  description = "ARN of the Scale In policy"
  value       = aws_autoscaling_policy.scale_in.arn
}

output "cpu_high_alarm_name" {
  description = "Name of the CPU High CloudWatch alarm"
  value       = aws_cloudwatch_metric_alarm.cpu_high.alarm_name
}

output "cpu_low_alarm_name" {
  description = "Name of the CPU Low CloudWatch alarm"
  value       = aws_cloudwatch_metric_alarm.cpu_low.alarm_name
}
