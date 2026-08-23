# Archivo: modules/networking/variables.tf

variable "location" {
  description = "Región de Azure donde se desplegarán los recursos de red"
  type        = string
}

variable "target_subscriptions" {
  description = "Mapa de IDs de suscripciones objetivo"
  type        = map(string)
}

variable "resource_group_names" {
  description = "Mapa global de nombres de Resource Groups provenientes del módulo resource_groups"
  type        = map(string)
}

variable "resource_group_tags" {
  description = "Mapa global de etiquetas de Resource Groups provenientes del módulo resource_groups"
  type        = map(map(string))
  default     = {}
}

variable "tags" {
  description = "Etiquetas corporativas de gobernanza por defecto"
  type        = map(string)
  default     = {}
}

variable "enable_global_peering" {
  description = "Indica si se habilita el Peering Global inter-región entre los Hubs (primary y dr)"
  type        = bool
  default     = false
}

variable "remote_hub_vnet_id" {
  description = "ID de la VNet del Hub remoto (p.ej. Hub DR en WestEurope cuando se despliega Primary en SwedenCentral, o viceversa)"
  type        = string
  default     = null
}