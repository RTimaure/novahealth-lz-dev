# Archivo: modules/resource_groups/variables.tf

variable "primary_location" {
  description = "Región principal de despliegue (ej. swedencentral)"
  type        = string
}

variable "dr_location" {
  description = "Región de contingencia / Disaster Recovery (ej. westeurope)"
  type        = string
}

variable "deployment_scope" {
  description = "Alcance de despliegue del módulo: primary o dr."
  type        = string

  validation {
    condition     = contains(["primary", "dr"], var.deployment_scope)
    error_message = "deployment_scope debe ser 'primary' o 'dr'."
  }
}