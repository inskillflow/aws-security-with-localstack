variable "project" {
  description = "Préfixe utilisé pour nommer les ressources."
  type        = string
  default     = "secdemo"
}

variable "log_group_retention_days" {
  description = "Rétention des logs en jours."
  type        = number
  default     = 14
}

variable "alarm_threshold_unauthorized" {
  description = "Seuil d'alarme pour les événements 'Unauthorized'."
  type        = number
  default     = 5
}
