variable "project" {
  description = "Préfixe utilisé pour nommer les ressources."
  type        = string
  default     = "secdemo"
}

variable "data_bucket_name" {
  description = "Nom du bucket S3 contenant les données sensibles."
  type        = string
  default     = "secdemo-data-bucket"
}

variable "logs_bucket_name" {
  description = "Nom du bucket S3 qui reçoit les access logs de data_bucket."
  type        = string
  default     = "secdemo-data-bucket-logs"
}
