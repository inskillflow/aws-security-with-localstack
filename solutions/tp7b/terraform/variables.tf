variable "project" {
  description = "Préfixe utilisé pour nommer les ressources."
  type        = string
  default     = "secdemo"
}

variable "lambda_runtime" {
  description = "Runtime Lambda."
  type        = string
  default     = "python3.11"
}
