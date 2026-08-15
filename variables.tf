# Archivo: variables.tf

variable "use_enterprise_subscriptions" {
  type        = bool
  description = "Interruptor de topología. Si es 'false', opera en Modo Estudiante (todo apunta a student_subscription_id). Si es 'true', opera en Modo Enterprise usando el mapa enterprise_subscriptions."
  default     = false
}

variable "student_subscription_id" {
  type        = string
  description = "ID de la suscripción de estudiante de Azure para pruebas y validaciones locales."
  default     = ""
}

variable "enterprise_subscriptions" {
  type        = map(string)
  description = "Mapa con los IDs de las 9 suscripciones creadas manualmente por la compañera para la topología de NovaHealth."
  default     = {}
}

variable "location" {
  type        = string
  description = "Región principal de Azure para el despliegue de los recursos."
  default     = "swedencentral"

  validation {
    condition     = contains(["swedencentral", "westeurope"], var.location)
    error_message = "ERROR DE POLÍTICA: La ubicación debe ser 'swedencentral' (Principal) o 'westeurope' (Disaster Recovery) según la directiva corporativa de NovaHealth."
  }
}

variable "primary_location" {
  type        = string
  description = "Región base de primary usada por módulos que distinguen primary y DR."
  default     = "swedencentral"
}

variable "dr_location" {
  type        = string
  description = "Región base de Disaster Recovery usada por módulos que distinguen primary y DR."
  default     = "westeurope"
}

variable "deployment_scope" {
  type        = string
  description = "Alcance del despliegue: primary o dr."
  default     = "primary"

  validation {
    condition     = contains(["primary", "dr"], var.deployment_scope)
    error_message = "deployment_scope debe ser 'primary' o 'dr'."
  }
}

variable "cicd_service_principal_object_id" {
  type    = string
  default = "" # O el valor que corresponda
}

variable "subscription_to_mg" {
  type        = map(string)
  description = "Para asociar cada suscripción con su Management Group correspondiente. Clave: nombre de la suscripción, Valor: ID del Management Group."

}

variable "tags" {
  type        = map(string)
  description = "Etiquetas aplicadas a los recursos"
  default     = {}
}
