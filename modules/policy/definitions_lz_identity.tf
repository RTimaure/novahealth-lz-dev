# Archivo: modules/policy/definitions_lz_identity.tf

# -------------------------------------------------------------------------
# DEFINICIONES CUSTOM - INICIATIVA LZ-IDENTITY
# -------------------------------------------------------------------------

locals {
  identity_policies = {
    "require_managed_identity" = {
      display_name = "Require Managed Identity on Compatible Services"
      description  = "Audita el uso de Managed Identity en App Services, Function Apps, AKS y Automation Accounts"
      mode         = "Indexed"
      metadata = jsonencode({
        category = "LZ-Identity"
        version  = "1.0.0"
      })
      policy_rule = jsonencode({
        if = {
          allOf = [
            {
              field = "type"
              in = [
                "Microsoft.Web/sites",
                "Microsoft.ContainerService/managedClusters",
                "Microsoft.Automation/automationAccounts"
              ]
            },
            {
              field  = "identity.type"
              equals = "None"
            }
          ]
        }
        then = {
          effect = "audit"
        }
      })
    }
    "enforce_conditional_access" = {
      display_name = "Enforce Conditional Access Policies"
      description  = "Audita que las políticas de Acceso Condicional estén habilitadas en Entra ID"
      mode         = "All"
      metadata = jsonencode({
        category = "LZ-Identity"
        version  = "1.0.0"
      })
      policy_rule = jsonencode({
        if = {
          field  = "type"
          equals = "Microsoft.Authorization/conditionalAccessPolicies"
        }
        then = {
          effect = "audit"
        }
      })
    }
  }
}

resource "azurerm_policy_definition" "lz_identity" {
  for_each            = local.identity_policies
  name                = "nh-id-${each.key}"
  policy_type         = "Custom"
  mode                = each.value.mode
  display_name        = each.value.display_name
  description         = each.value.description
  management_group_id = var.root_mg_id
  metadata            = each.value.metadata
  policy_rule         = each.value.policy_rule
}