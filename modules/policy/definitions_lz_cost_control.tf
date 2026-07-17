# Archivo: modules/policy/definitions_lz_cost_control.tf

# -------------------------------------------------------------------------
# DEFINICIONES CUSTOM - INICIATIVA LZ-COST-CONTROL
# -------------------------------------------------------------------------

locals {
  cost_control_policies = {
    "audit_budget_alerts" = {
      display_name = "Audit Subscriptions without Budget Alert"
      description  = "Audita suscripciones sin alertas de presupuesto configuradas para garantizar control financiero"
      mode         = "All"
      metadata = jsonencode({
        category = "LZ-Cost-Control"
        version  = "1.0.0"
      })
      policy_rule = jsonencode({
        if = {
          # 1. El objetivo de evaluación ahora es la Suscripción entera
          field  = "type"
          equals = "Microsoft.Resources/subscriptions"
        }
        then = {
          # 2. Cambiamos a AuditIfNotExists para buscar un recurso secundario
          effect = "AuditIfNotExists"
          details = {
            # 3. Azure buscará si existe un presupuesto dentro de esa suscripción
            type = "Microsoft.Consumption/budgets"
            
            # 4. Condición: Se considera "conforme" si el presupuesto existe y tiene un importe asignado
            existenceCondition = {
              field  = "Microsoft.Consumption/budgets/amount"
              exists = "true"
            }
          }
        }
      })
    }
  }
}


resource "azurerm_policy_definition" "lz_cost_control" {
  for_each            = local.cost_control_policies
  name                = "nh-cost-${each.key}"
  policy_type         = "Custom"
  mode                = each.value.mode
  display_name        = each.value.display_name
  description         = each.value.description
  management_group_id = var.root_mg_id
  metadata            = each.value.metadata
  policy_rule         = each.value.policy_rule
}