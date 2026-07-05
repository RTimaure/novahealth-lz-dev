# Archivo: modules/policy/policy_initiatives.tf

# -------------------------------------------------------------------------
# DEFINICIÓN DE INICIATIVAS (POLICY SETS) DE NOVAHEALTH
# -------------------------------------------------------------------------

# 1. Iniciativa LZ-Security
resource "azurerm_policy_set_definition" "lz_security" {
  name                = "nh-ini-lz-security"
  policy_type         = "Custom"
  display_name        = "NovaHealth Initiative: LZ Security"
  description         = "Agrupa directivas de seguridad corporativa para Landing Zones"
  management_group_id = var.root_mg_id

  policy_definition_reference {
    policy_definition_id = azurerm_policy_definition.deny_public_ip.id
    reference_id         = "DenyPublicIP"
  }
  policy_definition_reference {
    policy_definition_id = azurerm_policy_definition.enable_sentinel.id
    reference_id         = "EnableSentinel"
  }
}

# 2. Iniciativa LZ-Network-Security
resource "azurerm_policy_set_definition" "lz_network_security" {
  name                = "nh-ini-lz-net-sec"
  policy_type         = "Custom"
  display_name        = "NovaHealth Initiative: LZ Network Security"
  description         = "Controles de seguridad de red, DDoS y Private Endpoints"
  management_group_id = var.root_mg_id

  policy_definition_reference {
    policy_definition_id = azurerm_policy_definition.enforce_ddos.id
    reference_id         = "EnforceDDoS"
  }
  policy_definition_reference {
    policy_definition_id = azurerm_policy_definition.private_endpoints_only.id
    reference_id         = "PrivateEndpointsOnly"
  }
  policy_definition_reference {
    policy_definition_id = azurerm_policy_definition.deny_public_net_all.id
    reference_id         = "DenyPublicNetAll"
  }
  policy_definition_reference {
    policy_definition_id = azurerm_policy_definition.enforce_azure_firewall.id
    reference_id         = "EnforceAzureFirewall"
  }
}

# 3. Iniciativa LZ-Data
resource "azurerm_policy_set_definition" "lz_data" {
  name                = "nh-ini-lz-data"
  policy_type         = "Custom"
  display_name        = "NovaHealth Initiative: LZ Data Protection"
  description         = "Exige conectividad privada en almacenamiento y almacenes de claves"
  management_group_id = var.root_mg_id

  policy_definition_reference {
    policy_definition_id = azurerm_policy_definition.require_pe_storage.id
    reference_id         = "RequirePEStorage"
  }
  policy_definition_reference {
    policy_definition_id = azurerm_policy_definition.require_pe_kv.id
    reference_id         = "RequirePEKeyVault"
  }
}

# 4. Iniciativa LZ-Tagging
resource "azurerm_policy_set_definition" "lz_tagging" {
  name                = "nh-ini-lz-tagging"
  policy_type         = "Custom"
  display_name        = "NovaHealth Initiative: LZ Governance Tagging & Naming"
  description         = "Obliga etiquetas corporativas obligatorias y convención de nombres"
  management_group_id = var.root_mg_id

  dynamic "policy_definition_reference" {
    for_each = azurerm_policy_definition.require_tags
    content {
      policy_definition_id = policy_definition_reference.value.id
      reference_id         = "ReqTag${policy_definition_reference.key}"
    }
  }
  policy_definition_reference {
    policy_definition_id = azurerm_policy_definition.naming_convention.id
    reference_id         = "EnforceNamingConvention"
  }
}

# 5. Iniciativa LZ-Cost-Control
resource "azurerm_policy_set_definition" "lz_cost_control" {
  name                = "nh-ini-lz-cost"
  policy_type         = "Custom"
  display_name        = "NovaHealth Initiative: LZ Cost Control"
  description         = "Controles financieros y auditoría de alertas de presupuesto"
  management_group_id = var.root_mg_id

  policy_definition_reference {
    policy_definition_id = azurerm_policy_definition.lz_cost_control["audit_budget_alerts"].id
    reference_id         = "AuditBudgetAlerts"
  }
}

# 6. Iniciativa LZ-Identity
resource "azurerm_policy_set_definition" "lz_identity" {
  name                = "nh-ini-lz-identity"
  policy_type         = "Custom"
  display_name        = "NovaHealth Initiative: LZ Identity & Access"
  description         = "Auditoría de Managed Identities y políticas de Acceso Condicional"
  management_group_id = var.root_mg_id

  policy_definition_reference {
    policy_definition_id = azurerm_policy_definition.lz_identity["require_managed_identity"].id
    reference_id         = "RequireManagedIdentity"
  }
  policy_definition_reference {
    policy_definition_id = azurerm_policy_definition.lz_identity["enforce_conditional_access"].id
    reference_id         = "EnforceConditionalAccess"
  }
}

# 7. Iniciativa LZ-Networking
resource "azurerm_policy_set_definition" "lz_networking" {
  name                = "nh-ini-lz-networking"
  policy_type         = "Custom"
  display_name        = "NovaHealth Initiative: LZ Networking Architecture"
  description         = "Protege la topología Hub-and-Spoke limitando peerings no autorizados"
  management_group_id = var.root_mg_id

  policy_definition_reference {
    policy_definition_id = azurerm_policy_definition.lz_networking["deny_unauthorized_peering"].id
    reference_id         = "DenyUnauthorizedPeering"
  }
}