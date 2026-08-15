

# Archivo: modules/subscriptions/variables.tf

variable "management_group_ids" {
  description = "Mapa de IDs de los Management Groups creados"
  type        = map(string)
}

variable "use_enterprise_subscriptions" {
  description = "Flag para habilitar asociaciones empresariales BYOS"
  type        = bool
}

variable "enterprise_subscriptions" {
  description = "Mapa de nombres a IDs de suscripciones empresariales"
  type        = map(string)
  default     = {}
}

variable "subscription_to_mg" {
  description = "Mapa que asocia cada clave de suscripción con su Management Group correspondiente"
  type        = map(string)
  default     = {}
}

variable "student_subscription_id" {
  description = "ID de la suscripción de estudiante para modo pruebas"
  type        = string
  default     = ""
}