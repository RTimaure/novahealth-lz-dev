# Archivo: modules/policy/definitions_lz_networking.tf

# -------------------------------------------------------------------------
# DEFINICIONES CUSTOM - INICIATIVA LZ-NETWORKING
# -------------------------------------------------------------------------

locals {
  networking_policies = {
    "deny_unauthorized_peering" = {
      display_name = "Deny Unauthorized VNet Peering"
      description  = "Deniega peerings de VNet fuera de la topología Hub-Spoke aprobada por NovaHealth"
      mode         = "All"
      metadata = jsonencode({
        category = "LZ-Networking"
        version  = "1.0.0"
      })
      policy_rule = jsonencode({
        if = {
          allOf = [
            {
              field  = "type"
              equals = "Microsoft.Network/virtualNetworks/virtualNetworkPeerings"
            }
          ]
        }
        then = {
          effect = "audit"
        }
      })
    }
  }
}

resource "azurerm_policy_definition" "lz_networking" {
  for_each            = local.networking_policies
  name                = "nh-net-${each.key}"
  policy_type         = "Custom"
  mode                = each.value.mode
  display_name        = each.value.display_name
  description         = each.value.description
  management_group_id = var.root_mg_id
  metadata            = each.value.metadata
  policy_rule         = each.value.policy_rule
}