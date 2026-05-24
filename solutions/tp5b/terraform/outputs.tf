output "data_bucket" {
  description = "Nom du bucket de données."
  value       = aws_s3_bucket.data.bucket
}

output "logs_bucket" {
  description = "Nom du bucket de logs."
  value       = aws_s3_bucket.logs.bucket
}

output "kms_key_id" {
  description = "ID de la clé KMS."
  value       = aws_kms_key.data.key_id
}

output "kms_key_arn" {
  description = "ARN de la clé KMS."
  value       = aws_kms_key.data.arn
}

output "kms_alias" {
  description = "Alias humain de la clé KMS."
  value       = aws_kms_alias.data.name
}
