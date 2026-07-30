
# Archivo: modules/rbac/variables.tf

variable "root_mg_id" {
  type        = string
  description = "ID del Management Group raíz de NovaHealth"
}

variable "security_mg_id" {
  type        = string
  description = "ID del Management Group de seguridad"
}

variable "target_subscriptions" {
  type        = map(string)
  description = "Mapa de suscripciones objetivo desde el orquestador raíz"
}

variable "cicd_service_principal_object_id" {
  type        = string
  description = "Object ID del Service Principal utilizado para pipelines de CI/CD"
  default     = ""
}