# Archivo: modules/networking/variables.tf

variable "location" {
  type        = string
  description = "Región principal de despliegue para los recursos de red"
  default     = "swedencentral"
}

variable "target_subscriptions" {
  type        = map(string)
  description = "Mapa de suscripciones objetivo. Pasa por el embudo del main.tf raíz para soportar Modo Estudiante o Modo Enterprise."
}
variable "tags" {
  type        = map(string)
  description = "Etiquetas obligatorias para cumplir con la iniciativa de Gobierno (LZ-Tagging)"
  default     = {}
}