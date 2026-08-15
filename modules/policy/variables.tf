# Archivo: modules/policy/variables.tf

variable "root_mg_id" {
  description = "ID del Management Group raíz"
  type        = string
}

variable "platform_mg_id" {
  description = "ID del Management Group Platform"
  type        = string
  default     = null
}

variable "landing_zones_mg_id" {
  description = "ID del Management Group Landing Zones"
  type        = string
  default     = null
}

variable "management_group_ids" {
  description = "Mapa completo de IDs de Management Groups"
  type        = map(string)
  default     = {}
}

variable "target_subscriptions" {
  description = "Mapa de suscripciones objetivo"
  type        = map(string)
  default     = {}
}

variable "allowed_locations" {
  description = "Lista de regiones permitidas por Azure Policy"
  type        = list(string)
  default     = ["swedencentral", "westeurope"]
}