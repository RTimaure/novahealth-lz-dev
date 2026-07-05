# Archivo: modules/policy/definitions_lz_data.tf

# -------------------------------------------------------------------------
# DEFINICIONES CUSTOM - INICIATIVA LZ-DATA
# -------------------------------------------------------------------------

# 1. Require Private Endpoint - Storage
resource "azurerm_policy_definition" "require_pe_storage" {
  name                = "nh-require-pe-storage"
  policy_type         = "Custom"
  mode                = "Indexed"
  display_name        = "Require Private Endpoint for Storage Accounts"
  description         = "Obliga la conectividad privada para proteger datos clínicos"
  management_group_id = var.root_mg_id

  metadata = <<METADATA
    {
      "category": "LZ-Data",
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
            "count": {
              "field": "Microsoft.Storage/storageAccounts/privateEndpointConnections[*]"
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

# 2. Require Private Endpoint - Key Vault
resource "azurerm_policy_definition" "require_pe_kv" {
  name                = "nh-require-pe-kv"
  policy_type         = "Custom"
  mode                = "Indexed"
  display_name        = "Require Private Endpoint for Key Vaults"
  description         = "Obliga la conectividad privada en Key Vaults para proteger secretos"
  management_group_id = var.root_mg_id

  metadata = <<METADATA
    {
      "category": "LZ-Data",
      "version": "1.0.0"
    }
METADATA

  policy_rule = <<RULE
    {
      "if": {
        "allOf": [
          {
            "field": "type",
            "equals": "Microsoft.KeyVault/vaults"
          },
          {
            "count": {
              "field": "Microsoft.KeyVault/vaults/privateEndpointConnections[*]"
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