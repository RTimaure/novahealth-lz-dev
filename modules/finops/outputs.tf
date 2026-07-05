# Archivo: modules/finops/outputs.tf

output "budget_resource_ids" {
  description = "Mapa con los Resource IDs de los presupuestos de consumo configurados en Azure Cost Management."
  value = {
    for k, v in azurerm_consumption_budget_subscription.lz_budgets : k => v.id
  }
}

output "finops_summary" {
  description = "Resumen del modelo de presupuestos operacionales desplegado por suscripción."
  value = {
    for k, v in azurerm_consumption_budget_subscription.lz_budgets : k => {
      budget_name     = v.name
      monthly_limit   = v.amount
      subscription_id = v.subscription_id
    }
  }
}