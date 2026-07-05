# Archivo: modules/policy/variables.tf

variable "root_mg_id" {
  type        = string
  description = "ID del Management Group raíz de NovaHealth (nh-root)"
}

variable "landing_zones_mg_id" {
  type        = string
  description = "ID del Management Group de Landing Zones (nh-landing-zones)"
}

variable "platform_mg_id" {
  type        = string
  description = "ID del Management Group de Platform (nh-platform)"
}

variable "target_subscriptions" {
  type        = map(string)
  description = "Mapa de suscripciones objetivo desde el orquestador raíz"
  default     = {}
}