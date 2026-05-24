variable "project" {
  description = "Préfixe utilisé pour nommer les ressources IAM."
  type        = string
  default     = "secdemo"
}

variable "demo_bucket_name" {
  description = "Nom du bucket S3 cible utilisé dans les policies (le bucket lui-même peut être créé hors de ce module)."
  type        = string
  default     = "secdemo-shared-bucket"
}
