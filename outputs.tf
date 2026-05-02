output "http_listener_arn" {
  description = "ARN of HTTP:80 Listener — used by Listener Rules branch"
  value       = aws_lb_listener.http_listener.arn
}
