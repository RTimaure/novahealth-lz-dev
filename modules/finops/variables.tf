# Archivo: modules/finops/variables.tf

variable "target_subscriptions" {
  type        = map(string)
  description = "Mapa desacoplado de suscripciones objetivo (proyectado mediante el embudo locals.target_subscriptions desde la raíz)."
}

variable "notification_emails" {
  type        = list(string)
  description = "Lista de correos electrónicos del equipo FinOps y de los Owners para recibir notificaciones de alertas de consumo."
  default     = ["finops-team@novahealth.com", "cloud-governance@novahealth.com"]
}