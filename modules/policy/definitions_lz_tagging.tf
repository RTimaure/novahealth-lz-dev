# Archivo: modules/policy/definitions_lz_tagging.tf

# ==============================================================================
# 1. POLÍTICA DE CONVENCIÓN DE NOMBRES (CLUSTERS C1, C2, C3, C4)
# ==============================================================================
resource "azurerm_policy_definition" "enforce_naming" {
  name                = "nh-enforce-naming"
  policy_type         = "Custom"
  mode                = "All"
  display_name        = "Enforce Naming Convention (Clusters C1-C4)"
  description         = "Aplica la convención de nomenclatura corporativa de NovaHealth: C1 (4 segmentos), C2 (5 segmentos), C3 (3 segmentos), C4 Storage Accounts (sin guiones)."
  management_group_id = var.root_mg_id

  metadata = <<METADATA
    {
      "category": "Tagging and Naming",
      "version": "2.0.0"
    }
  METADATA

  policy_rule = <<POLICY_RULE
  {
    "if": {
      "anyOf": [
        {
          "allOf": [
            {
              "field": "type",
              "in": [
                "Microsoft.Resources/subscriptions/resourceGroups",
                "Microsoft.Network/virtualNetworks",
                "Microsoft.Network/routeTables",
                "Microsoft.Network/applicationGateways",
                "Microsoft.Sql/servers/databases",
                "Microsoft.ContainerRegistry/registries",
                "Microsoft.OperationalInsights/workspaces",
                "microsoft.insights/workbooks",
                "microsoft.insights/actionGroups"
              ]
            },
            {
              "value": "[length(split(field('name'), '-'))]",
              "notEquals": 4
            }
          ]
        },
        {
          "allOf": [
            {
              "field": "type",
              "in": [
                "Microsoft.Network/virtualNetworks/subnets",
                "Microsoft.Compute/virtualMachines",
                "Microsoft.KeyVault/vaults",
                "Microsoft.Network/networkSecurityGroups",
                "Microsoft.Network/publicIPAddresses",
                "Microsoft.Network/privateEndpoints"
              ]
            },
            {
              "field": "name",
              "notIn": ["AzureFirewallSubnet", "GatewaySubnet", "AzureBastionSubnet"]
            },
            {
              "value": "[length(split(field('name'), '-'))]",
              "notEquals": 5
            }
          ]
        },
        {
          "allOf": [
            {
              "field": "type",
              "in": [
                "Microsoft.Network/virtualNetworkGateways",
                "Microsoft.Network/azureFirewalls",
                "Microsoft.Network/firewallPolicies",
                "Microsoft.Network/bastionHosts"
              ]
            },
            {
              "value": "[length(split(field('name'), '-'))]",
              "notEquals": 3
            }
          ]
        },
        {
          "allOf": [
            {
              "field": "type",
              "equals": "Microsoft.Storage/storageAccounts"
            },
            {
              "field": "name",
              "contains": "-"
            }
          ]
        }
      ]
    },
    "then": {
      "effect": "Deny"
    }
  }
  POLICY_RULE
}

# ==============================================================================
# 2. POLÍTICA DE ETIQUETAS OBLIGATORIAS (7 TAGS CORPORATIVOS)
# ==============================================================================
resource "azurerm_policy_definition" "require_mandatory_tags" {
  name                = "nh-require-mandatory-tags"
  policy_type         = "Custom"
  mode                = "Indexed"
  display_name        = "Require Mandatory Tags (NovaHealth 7 Fields)"
  description         = "Exige la presencia de las 7 etiquetas corporativas (environment, owner, cost-center, project, businessUnit, criticality, region) y valida que el owner comience con grp-novahealth-*."
  management_group_id = var.root_mg_id

  metadata = <<METADATA
    {
      "category": "Tagging and Naming",
      "version": "2.0.0"
    }
  METADATA

  policy_rule = <<POLICY_RULE
  {
    "if": {
      "anyOf": [
        { "field": "tags['environment']", "exists": "false" },
        { "field": "tags['owner']", "exists": "false" },
        {
          "allOf": [
            { "field": "tags['owner']", "exists": "true" },
            { "field": "tags['owner']", "notLike": "grp-novahealth-*" }
          ]
        },
        { "field": "tags['cost-center']", "exists": "false" },
        { "field": "tags['project']", "exists": "false" },
        { "field": "tags['businessUnit']", "exists": "false" },
        { "field": "tags['criticality']", "exists": "false" },
        { "field": "tags['region']", "exists": "false" }
      ]
    },
    "then": {
      "effect": "Deny"
    }
  }
  POLICY_RULE
}