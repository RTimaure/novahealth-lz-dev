# Archivo: modules/observability/variables.tf

variable "location" {
  description = "Región principal de despliegue para los recursos de observabilidad (p. ej. swedencentral)"
  type        = string
}

variable "resource_group_names" {
  description = "Mapa de nombres de Resource Groups exportados por el módulo de resource_groups"
  type        = map(string)
}

variable "resource_group_tags" {
  description = "Mapa de etiquetas de Resource Groups exportados por el módulo de resource_groups"
  type        = map(map(string))
  default     = {}
}

variable "tags" {
  description = "Mapa de etiquetas corporativas de NovaHealth"
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


# 🆕 AÑADE ESTA VARIABLE (Controlará los counts de forma segura)
variable "enabled_features" {
  type = object({
    firewall            = bool
    application_gateway = bool
    vpn_gateway         = bool
    bastion             = bool
    dns_resolver        = bool
  })
  default = {
    firewall            = true
    application_gateway = true
    vpn_gateway         = true
    bastion             = true
    dns_resolver        = true
  }
}
