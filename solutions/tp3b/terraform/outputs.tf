output "developers_group_arn" {
  description = "ARN du groupe developers."
  value       = aws_iam_group.developers.arn
}

output "auditors_group_arn" {
  description = "ARN du groupe auditors."
  value       = aws_iam_group.auditors.arn
}

output "alice_arn" {
  description = "ARN du user alice."
  value       = aws_iam_user.alice.arn
}

output "bob_arn" {
  description = "ARN du user bob."
  value       = aws_iam_user.bob.arn
}

output "bucket_read_policy_arn" {
  description = "ARN de la policy bucket-read."
  value       = aws_iam_policy.bucket_read.arn
}

output "bucket_write_policy_arn" {
  description = "ARN de la policy bucket-write."
  value       = aws_iam_policy.bucket_write.arn
}

output "lambda_role_arn" {
  description = "ARN du role d'execution Lambda."
  value       = aws_iam_role.lambda_exec.arn
}

output "demo_bucket" {
  description = "Bucket S3 cible utilise dans les policies."
  value       = aws_s3_bucket.demo.bucket
}
