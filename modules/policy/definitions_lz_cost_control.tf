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
              field = "Microsoft.Consumption/budgets/amount"
              //"greater": 0
              exists = "true"
            }
          }
        }
      })
    },
    "allowed_vm_skus" = {
      display_name = "Allowed Virtual Machine SKUs (NovaHealth Cost Control)"
      description  = "Restringe el despliegue de máquinas virtuales únicamente a las familias de SKUs corporativas aprobadas para control de costes (Standard_D2s_v5, Standard_D4s_v5, Standard_B2s_v2, Standard_B4s_v2)"
      mode         = "Indexed"
      metadata = jsonencode({
        category = "LZ-Cost-Control"
        version  = "1.0.0"
      })
      policy_rule = jsonencode({
        if = {
          allOf = [
            {
              field  = "type"
              equals = "Microsoft.Compute/virtualMachines"
            },
            {
              not = {
                field = "Microsoft.Compute/virtualMachines/sku.name"
                in = [
                  "Standard_B2pls_v2",
                  "Standard_B2ps_v2",
                  "Standard_B4pls_v2",
                  "Standard_B4ps_v2",
                  "Standard_D2ds_v6",
                  "Standard_D4s_v6"
                ]
              }
            }
          ]
        }
        then = {
          effect = "Deny"
        }
      })
    },
    "allowed_resource_types" = {
      display_name = "Allowed Resource Types (NovaHealth Cost Control)"
      description  = "Restringe los tipos de recursos autorizados que se pueden desplegar en las Landing Zones corporativas"
      mode         = "Indexed"
      metadata = jsonencode({
        category = "LZ-Cost-Control"
        version  = "1.0.0"
      })
      policy_rule = jsonencode({
        if = {
          not = {
            field = "type"
            in    = var.allowed_resource_types
          }
        }
        then = {
          effect = "Deny"
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