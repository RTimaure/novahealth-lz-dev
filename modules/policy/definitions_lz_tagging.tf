# Archivo: modules/policy/definitions_lz_tagging.tf

# ==============================================================================
# 1. POLÍTICA DE CONVENCIÓN DE NOMBRES (CLUSTERS C1 A C6)
# ==============================================================================
# C1: <prefix>-<scope>-<environment>-<region> (4 segmentos) -> Resource Group, VNet, Route Table, App Gateway, SQL Database, ACR, Log Analytics, Workbook, Action Group
# C2: <prefix>-<source>-<target>-<environment>-<region> (5 segmentos) -> VNet Peering
# C3: <prefix>-<scope>-<subnet>-<environment>-<region> (5 segmentos) -> Subnet, NSG (Excepciones built-in: AzureFirewallSubnet, GatewaySubnet, AzureBastionSubnet)
# C4: <prefix>-<scope>-<environment>-<region>-<nnn> (5 segmentos) -> Virtual Machine, Key Vault, Public IP, Private Endpoint
# C5: <prefix>-<environment>-<region> (3 segmentos) -> Azure Firewall, Firewall Policy, VPN Gateway, Bastion, DNS Private Resolver
# C6: <prefix><scope><environment><nnn> (alfanumérico sin guiones) -> Storage Account
# ==============================================================================
resource "azurerm_policy_definition" "enforce_naming" {
  name                = "nh-enforce-naming"
  policy_type         = "Custom"
  mode                = "All"
  display_name        = "Enforce Naming Convention (Clusters C1-C6)"
  description         = "Aplica la convención de nomenclatura corporativa de NovaHealth: C1 (Ámbito: 4 segs), C2 (Relaciones/Peering: 5 segs), C3 (Subnet/NSG: 5 segs), C4 (Multi-instancia: 5 segs), C5 (Transversales únicos: 3 segs), C6 (Storage: alfanumérico sin guiones)."
  management_group_id = var.root_mg_id

  metadata = <<METADATA
    {
      "category": "Tagging and Naming",
      "version": "3.0.0"
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
                "Microsoft.Network/virtualNetworks/virtualNetworkPeerings"
              ]
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
                "Microsoft.Network/virtualNetworks/subnets",
                "Microsoft.Network/networkSecurityGroups"
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
                "Microsoft.Compute/virtualMachines",
                "Microsoft.KeyVault/vaults",
                "Microsoft.Network/publicIPAddresses",
                "Microsoft.Network/privateEndpoints"
              ]
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
                "Microsoft.Network/azureFirewalls",
                "Microsoft.Network/firewallPolicies",
                "Microsoft.Network/virtualNetworkGateways",
                "Microsoft.Network/bastionHosts",
                "Microsoft.Network/dnsResolvers"
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
# 2. POLÍTICA DE ETIQUETAS OBLIGATORIAS (8 TAGS CORPORATIVOS OFICIALES)
# ==============================================================================
# 1. environmentType: primary | dr
# 2. environment: prod | qa | dev | sandbox
# 3. region: SwedenCentral | WestEurope
# 4. owner: grp-novahealth-*
# 5. costCenter: CC-001 a CC-009
# 6. project: NovaHealth-LandingZone
# 7. workload: platformshared-services | hospital-systems | telemedicine | medical-imaging | clinical-ai | security-compliance
# 8. criticality: Critical | High | Medium | Low
# ==============================================================================
resource "azurerm_policy_definition" "require_mandatory_tags" {
  name                = "nh-require-mandatory-tags"
  policy_type         = "Custom"
  mode                = "Indexed"
  display_name        = "Require Mandatory Tags (NovaHealth 8 Fields)"
  description         = "Exige la presencia de las 8 etiquetas corporativas (environmentType, environment, region, owner, costCenter, project, workload, criticality) tanto en Resource Groups como en recursos, y valida que el owner comience con grp-novahealth-*."
  management_group_id = var.root_mg_id

  metadata = <<METADATA
    {
      "category": "Tagging and Naming",
      "version": "4.0.0"
    }
  METADATA

  policy_rule = <<POLICY_RULE
  {
    "if": {
      "anyOf": [
        { "field": "tags['environmentType']", "exists": "false" },
        { "field": "tags['environment']", "exists": "false" },
        { "field": "tags['region']", "exists": "false" },
        { "field": "tags['owner']", "exists": "false" },
        {
          "allOf": [
            { "field": "tags['owner']", "exists": "true" },
            { "field": "tags['owner']", "notLike": "grp-novahealth-*" }
          ]
        },
        { "field": "tags['costCenter']", "exists": "false" },
        { "field": "tags['project']", "exists": "false" },
        { "field": "tags['workload']", "exists": "false" },
        { "field": "tags['criticality']", "exists": "false" }
      ]
    },
    "then": {
      "effect": "Deny"
    }
  }
  POLICY_RULE
}