# Archivo: modules/subscriptions/outputs.tf

output "subscription_ids" {
  description = "Mapa normalizado con los IDs de las suscripciones procesadas"
  value       = var.use_enterprise_subscriptions ? var.enterprise_subscriptions : { student = var.student_subscription_id }
}