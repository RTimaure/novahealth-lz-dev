# Archivo: modules/observability/variables.tf

variable "location" {
  description = "Región principal de despliegue para los recursos de observabilidad (p. ej. swedencentral)"
  type        = string
}

variable "resource_group_names" {
  description = "Mapa de nombres de Resource Groups exportados por el módulo de resource_groups"
  type        = map(string)
}

variable "tags" {
  description = "Mapa de 7 etiquetas corporativas obligatorias de NovaHealth"
  type        = map(string)
  default     = {}
}

variable "log_analytics_retention_in_days" {
  description = "Días de retención para el Log Analytics Workspace (retención por defecto: 30 días)"
  type        = number
  default     = 30
}

variable "notification_email" {
  description = "Email principal para recepcionar alertas de la plataforma NovaHealth"
  type        = string
  default     = "ops-alerts@novahealth.com"
}
