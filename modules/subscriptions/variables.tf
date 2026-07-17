# Archivo: modules/subscriptions/variables.tf

variable "use_enterprise_subscriptions" {
  type        = bool
  description = "Define si se opera en modo BYOS Enterprise (true) o en Modo Estudiante (false)"
}

variable "student_subscription_id" {
  type        = string
  description = "ID de la suscripción de estudiante para mover bajo nh-root"
  default     = ""
}

variable "enterprise_subscriptions" {
  type        = map(string)
  description = "Mapa con los IDs de las suscripciones empresariales para BYOS"
  default     = {}
}

variable "management_group_ids" {
  type        = map(string)
  description = "Mapa con los IDs de los Management Groups generados en la Capa 1"
  default     = {}
}

variable "subscription_to_mg" {
  description = "Mapa de asignación entre suscripciones y Management Groups."
  type        = map(string)
}