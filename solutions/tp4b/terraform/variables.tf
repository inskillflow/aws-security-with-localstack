variable "project" {
  description = "Préfixe utilisé pour nommer les ressources réseau."
  type        = string
  default     = "secdemo"
}

variable "vpc_cidr" {
  description = "CIDR du VPC."
  type        = string
  default     = "10.0.0.0/16"
}

variable "public_subnet_cidr" {
  description = "CIDR du subnet public."
  type        = string
  default     = "10.0.1.0/24"
}

variable "private_subnet_cidr" {
  description = "CIDR du subnet privé."
  type        = string
  default     = "10.0.2.0/24"
}

variable "az" {
  description = "Zone de disponibilité."
  type        = string
  default     = "us-east-1a"
}
