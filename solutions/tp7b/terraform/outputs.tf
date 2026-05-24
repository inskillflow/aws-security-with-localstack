output "lambda_arn" {
  description = "ARN de la Lambda d'auto-remédiation."
  value       = aws_lambda_function.remediation.arn
}

output "lambda_name" {
  description = "Nom de la Lambda d'auto-remédiation."
  value       = aws_lambda_function.remediation.function_name
}

output "event_rule_name" {
  description = "Nom de la règle EventBridge."
  value       = aws_cloudwatch_event_rule.on_create_bucket.name
}

output "role_arn" {
  description = "ARN du rôle d'exécution."
  value       = aws_iam_role.remediation.arn
}
