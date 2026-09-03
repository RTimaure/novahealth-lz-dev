variable "location" {
	description = "Región de despliegue para primary."
	type        = string
	default     = "swedencentral"

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
	default     = "primary"

	validation {
		condition     = contains(["primary", "dr"], var.deployment_scope)
		error_message = "deployment_scope debe ser primary o dr."
	}
}

variable "use_enterprise_subscriptions" {
	description = "Activa el modo enterprise para asociar suscripciones reales."
	type        = bool
	default     = true
}

variable "enterprise_subscriptions" {
	description = "Mapa de suscripciones enterprise del entorno primary."
	type        = map(string)
	default     = {}
}

variable "subscription_to_mg" {
	description = "Mapa de asociación entre suscripciones y management groups."
	type        = map(string)
	default     = {}
}

variable "student_subscription_id" {
	description = "ID de suscripción de estudiante, mantenido por compatibilidad."
	type        = string
	default     = ""
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
	description = "Etiquetas corporativas aplicadas a primary."
	type        = map(string)
	default     = {}
}

variable "enable_global_peering" {
	description = "Habilita el peering global inter-región con el Hub DR."
	type        = bool
	default     = false
}

variable "remote_hub_vnet_id" {
	description = "ID opcional de la VNet del Hub DR en WestEurope."
	type        = string
	default     = null
}

variable "cicd_service_principal_object_id" {

	description = "Object ID del service principal de CI/CD."
	type        = string
	default     = ""
}

#--------------------------------------------
# Variables para el módulo de Jumpbox
#--------------------------------------------
variable "jumpbox_admin_username" {
	description = "Usuario administrador de la jumpbox"
	type        = string
	default     = "nh-jumpbox-admin"
}

variable "jumpbox_admin_password" {
	description = "Contraseña del usuario administrador de la jumpbox"
	type        = string
	sensitive   = true
}

#--------------------------------------------
# Variables para el módulo de VM Tester
#--------------------------------------------

variable "test_vm_spoke" {
  description = "Spoke destino de la VM de pruebas: aks | apps | dataai | shared"
  type        = string

  validation {
    condition     = contains(["aks", "apps", "dataai", "shared"], var.test_vm_spoke)
    error_message = "test_vm_spoke debe ser uno de: aks, apps, dataai, shared."
  }
}

variable "test_vm_admin_password" {
  description = "Contraseña del usuario administrador local de las VMs de prueba (sensible; no se abre el puerto 22 por red)."
  type        = string
  sensitive   = true
}
