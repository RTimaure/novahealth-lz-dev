# Archivo: modules/policy/definitions_lz_security.tf

# -------------------------------------------------------------------------
# DEFINICIONES CUSTOM - INICIATIVA LZ-SECURITY
# -------------------------------------------------------------------------

# Archivo: modules/policy/policy_definitions.tf

# 1. Deny Public IP (Con exclusiones corporativas estrictas para Hub Network)
resource "azurerm_policy_definition" "deny_public_ip" {
  name                = "nh-deny-public-ip"
  policy_type         = "Custom"
  mode                = "All"
  display_name        = "Deny Public IP in NovaHealth Landing Zones"
  description         = "Impide la creación de IPs públicas no autorizadas, excluyendo explícitamente aquellas destinadas a Firewall, Bastion y VPN GW mediante convención de nombres."
  management_group_id = var.root_mg_id

  metadata = <<METADATA
    {
      "category": "LZ-Security",
      "version": "1.1.0"
    }
METADATA

  # CORRECCIÓN DEVOPS: Se añaden cláusulas 'not' usando el operador 'like' 
  # para excluir los nombres reservados de los recursos core de red.
  policy_rule = <<RULE
    {
      "if": {
        "allOf": [
          {
            "field": "type",
            "equals": "Microsoft.Network/publicIPAddresses"
          },
          {
            "not": {
              "field": "name",
              "like": "pip-fw-*"
            }
          },
          {
            "not": {
              "field": "name",
              "like": "pip-bastion-*"
            }
          },
          {
            "not": {
              "field": "name",
              "like": "pip-vpngw-*"
            }
          }
        ]
      },
      "then": {
        "effect": "deny"
      }
    }
RULE
}

# 2. Enable Microsoft Sentinel (Custom Audit usando alias soportado)
resource "azurerm_policy_definition" "enable_sentinel" {
  name                = "nh-enable-sentinel"
  policy_type         = "Custom"
  mode                = "All"
  display_name        = "Enable Microsoft Sentinel"
  description         = "Audita soluciones de gestión de logs que no estén vinculadas a un área de trabajo Sentinel"
  management_group_id = var.root_mg_id

  metadata = <<METADATA
    {
      "category": "LZ-Security",
      "version": "1.0.0"
    }
METADATA

  policy_rule = <<RULE
    {
      "if": {
        "allOf": [
          {
            "field": "type",
            "equals": "Microsoft.OperationsManagement/solutions"
          },
          {
            "field": "Microsoft.OperationsManagement/solutions/workspaceResourceId",
            "exists": "false"
          }
        ]
      },
      "then": {
        "effect": "audit"
      }
    }
RULE
}