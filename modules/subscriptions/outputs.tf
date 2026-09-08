# Archivo: modules/subscriptions/outputs.tf

output "subscription_ids" {
  description = "Mapa unificado de IDs de suscripciones activas (Enterprise o Estudiante)"
  value = var.use_enterprise_subscriptions ? var.enterprise_subscriptions : {
    connectivity      = var.student_subscription_id
    identity          = var.student_subscription_id
    management        = var.student_subscription_id
    production        = var.student_subscription_id
    platform_services = var.student_subscription_id
  }
}