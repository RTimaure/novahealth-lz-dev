# Archivo: modules/policy/policy_assignments.tf

# -------------------------------------------------------------------------
# ASIGNACIONES DE INICIATIVAS CORPORATIVAS (AZURE POLICY SET ASSIGNMENTS)
# -------------------------------------------------------------------------

locals {
  initiative_assignments = {
    "assign_lz_security" = {
      name         = "asgn-ini-security"
      scope        = var.landing_zones_mg_id
      initiative   = azurerm_policy_set_definition.lz_security.id
      display_name = "Assign: NovaHealth LZ Security Initiative"
    }
    "assign_lz_net_sec" = {
      name         = "asgn-ini-netsec"
      scope        = var.root_mg_id
      initiative   = azurerm_policy_set_definition.lz_network_security.id
      display_name = "Assign: NovaHealth LZ Network Security Initiative"
    }
    "assign_lz_data" = {
      name         = "asgn-ini-data"
      scope        = var.root_mg_id
      initiative   = azurerm_policy_set_definition.lz_data.id
      display_name = "Assign: NovaHealth LZ Data Protection Initiative"
    }
    "assign_lz_tagging" = {
      name         = "asgn-ini-tagging"
      scope        = var.root_mg_id
      initiative   = azurerm_policy_set_definition.lz_tagging.id
      display_name = "Assign: NovaHealth LZ Governance Tagging Initiative"
    }
    "assign_lz_cost" = {
      name         = "asgn-ini-cost"
      scope        = var.root_mg_id
      initiative   = azurerm_policy_set_definition.lz_cost_control.id
      display_name = "Assign: NovaHealth LZ Cost Control Initiative"
    }
    "assign_lz_identity" = {
      name         = "asgn-ini-id"
      scope        = var.root_mg_id
      initiative   = azurerm_policy_set_definition.lz_identity.id
      display_name = "Assign: NovaHealth LZ Identity Initiative"
    }
    "assign_lz_networking" = {
      name         = "asgn-ini-net"
      scope        = var.platform_mg_id
      initiative   = azurerm_policy_set_definition.lz_networking.id
      display_name = "Assign: NovaHealth LZ Networking Initiative"
    }
  }
}

resource "azurerm_management_group_policy_assignment" "builtin" {
  for_each             = local.initiative_assignments
  name                 = each.value.name
  management_group_id  = each.value.scope
  policy_definition_id = each.value.initiative
  display_name         = each.value.display_name
}