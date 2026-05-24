output "log_group_name" {
  description = "Nom du log group applicatif."
  value       = aws_cloudwatch_log_group.app.name
}

output "metric_filter_unauthorized" {
  description = "Nom du metric filter Unauthorized."
  value       = aws_cloudwatch_log_metric_filter.unauthorized.name
}

output "alarm_name" {
  description = "Nom de l'alarme."
  value       = aws_cloudwatch_metric_alarm.too_many_unauthorized.alarm_name
}

output "sns_topic_arn" {
  description = "ARN du topic SNS d'alerte."
  value       = aws_sns_topic.security_alerts.arn
}
