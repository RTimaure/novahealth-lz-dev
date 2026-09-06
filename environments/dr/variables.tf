variable "location" {
  description = "Región de despliegue para DR."
  type        = string
  default     = "westeurope"

  validation {
    condition     = contains(["swedencentral", "westeurope"], var.location)
    error_message = "La ubicación debe ser swedencentral o westeurope."
  }
}

variable "primary_location" {
  description = "Región primaria."
  type        = string
  default     = "swedencentral"
}

variable "dr_location" {
  description = "Región DR."
  type        = string
  default     = "westeurope"
}

variable "deployment_scope" {
  description = "Alcance del despliegue físico."
  type        = string
  default     = "dr"

  validation {
    condition     = contains(["primary", "dr"], var.deployment_scope)
    error_message = "deployment_scope debe ser primary o dr."
  }
}

variable "connectivity_subscription_id" {
  description = "Subscription ID de connectivity."
  type        = string
}

variable "identity_subscription_id" {
  description = "Subscription ID de identity."
  type        = string
}

variable "management_subscription_id" {
  description = "Subscription ID de management."
  type        = string
}

variable "production_subscription_id" {
  description = "Subscription ID de production."
  type        = string
}

variable "data_ai_subscription_id" {
  description = "Subscription ID de data_ai."
  type        = string
}

variable "tags" {
  description = "Etiquetas corporativas aplicadas a DR."
  type        = map(string)
  default     = {}
}

variable "enable_global_peering" {
  description = "Habilita el peering global inter-región con el Hub Primario."
  type        = bool
  default     = false
}

variable "remote_hub_vnet_id" {
  description = "ID opcional de la VNet del Hub Primario en SwedenCentral."
  type        = string
  default     = null
}

