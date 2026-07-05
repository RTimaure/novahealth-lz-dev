# Archivo: modules/policy/definitions_lz_network_security.tf

# -------------------------------------------------------------------------
# DEFINICIONES CUSTOM - INICIATIVA LZ-NETWORK-SECURITY
# -------------------------------------------------------------------------

# 1. Enforce DDoS Protection
resource "azurerm_policy_definition" "enforce_ddos" {
  name                = "nh-enforce-ddos"
  policy_type         = "Custom"
  mode                = "All"
  display_name        = "Enforce DDoS Protection on Virtual Networks"
  description         = "Audita VNets sin Azure DDoS Protection habilitado para proteger servicios críticos"
  management_group_id = var.root_mg_id

  metadata = <<METADATA
    {
      "category": "LZ-Network-Security",
      "version": "1.0.0"
    }
METADATA

  policy_rule = <<RULE
    {
      "if": {
        "allOf": [
          {
            "field": "type",
            "equals": "Microsoft.Network/virtualNetworks"
          },
          {
            "field": "Microsoft.Network/virtualNetworks/enableDdosProtection",
            "notEquals": true
          }
        ]
      },
      "then": {
        "effect": "audit"
      }
    }
RULE
}

# 2. Private Endpoints Only - Deny
resource "azurerm_policy_definition" "private_endpoints_only" {
  name                = "nh-private-endpoints-only"
  policy_type         = "Custom"
  mode                = "All"
  display_name        = "Private Endpoints Only - Deny"
  description         = "Deniega recursos críticos compatibles con Private Endpoint sin conectividad privada"
  management_group_id = var.root_mg_id

  metadata = <<METADATA
    {
      "category": "LZ-Network-Security",
      "version": "1.0.0"
    }
METADATA

  policy_rule = <<RULE
    {
      "if": {
        "allOf": [
          {
            "field": "type",
            "equals": "Microsoft.Storage/storageAccounts"
          },
          {
            "field": "Microsoft.Storage/storageAccounts/publicNetworkAccess",
            "equals": "Enabled"
          }
        ]
      },
      "then": {
        "effect": "deny"
      }
    }
RULE
}

# 3. Deny Public Network Access - Storage & PaaS
resource "azurerm_policy_definition" "deny_public_net_all" {
  name                = "nh-deny-pubnet-all"
  policy_type         = "Custom"
  mode                = "All"
  display_name        = "Deny Public Network Access - Storage Resources"
  description         = "Deniega la creación de Storage Accounts con acceso público en entornos productivos"
  management_group_id = var.root_mg_id

  metadata = <<METADATA
    {
      "category": "LZ-Network-Security",
      "version": "1.0.0"
    }
METADATA

  policy_rule = <<RULE
    {
      "if": {
        "allOf": [
          {
            "field": "type",
            "equals": "Microsoft.Storage/storageAccounts"
          },
          {
            "field": "Microsoft.Storage/storageAccounts/publicNetworkAccess",
            "notEquals": "Disabled"
          }
        ]
      },
      "then": {
        "effect": "audit"
      }
    }
RULE
}

# 4. Enforce Azure Firewall en Hub VNet (Sintaxis ARM de un solo comodín en like)
resource "azurerm_policy_definition" "enforce_azure_firewall" {
  name                = "nh-enforce-firewall"
  policy_type         = "Custom"
  mode                = "All"
  display_name        = "Enforce Azure Firewall"
  description         = "Audita VNets de Hub que no dispongan de la subred dedicada AzureFirewallSubnet"
  management_group_id = var.root_mg_id

  metadata = <<METADATA
    {
      "category": "LZ-Network-Security",
      "version": "1.0.0"
    }
METADATA

  policy_rule = <<RULE
    {
      "if": {
        "allOf": [
          {
            "field": "type",
            "equals": "Microsoft.Network/virtualNetworks"
          },
          {
            "field": "name",
            "like": "vnet-hub*"
          },
          {
            "count": {
              "field": "Microsoft.Network/virtualNetworks/subnets[*]",
              "where": {
                "field": "Microsoft.Network/virtualNetworks/subnets[*].name",
                "equals": "AzureFirewallSubnet"
              }
            },
            "less": 1
          }
        ]
      },
      "then": {
        "effect": "audit"
      }
    }
RULE
}