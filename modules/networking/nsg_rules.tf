# Archivo: modules/networking/nsg_rules.tf

locals {
  # -----------------------------------------------------------------------
  # 1. REGLAS HUB
  # -----------------------------------------------------------------------
  hub_nsg_rules_raw = flatten([
    [for env in ["prod", "nprod"] :
      [for r in [
        { name = "Allow-GatewayManager-In", priority = 100, direction = "Inbound", source = "GatewayManager",     dest = "*", port = "65200-65535", protocol = "Tcp", access = "Allow" },
        { name = "Allow-AzureLB-In",         priority = 110, direction = "Inbound", source = "AzureLoadBalancer", dest = "*", port = "*",           protocol = "*",   access = "Allow" },
        { name = "Allow-Internet-HTTP-In",   priority = 120, direction = "Inbound", source = "Internet",          dest = "*", port = "80,443",       protocol = "Tcp", access = "Allow" }
      ] : merge(r, { nsg_key = "hub_${env}_snet-hub-appgw-${env}-swe" })]
    ],

    [for env in ["prod", "nprod"] :
      [for r in [
        { name = "AllowHttpsInbound",          priority = 120, direction = "Inbound",  source = "Internet",          dest = "*",              port = "443",       protocol = "Tcp", access = "Allow" },
        { name = "AllowGatewayManagerInbound", priority = 130, direction = "Inbound",  source = "GatewayManager",    dest = "*",              port = "443",       protocol = "Tcp", access = "Allow" },
        { name = "AllowAzureLBInbound",        priority = 140, direction = "Inbound",  source = "AzureLoadBalancer", dest = "*",              port = "443",       protocol = "Tcp", access = "Allow" },
        { name = "AllowBastionHostCommIn",     priority = 150, direction = "Inbound",  source = "VirtualNetwork",    dest = "VirtualNetwork", port = "8080,5701", protocol = "*",   access = "Allow" },
        { name = "AllowSshRdpOutbound",        priority = 100, direction = "Outbound", source = "*",                 dest = "VirtualNetwork", port = "22,3389",   protocol = "*",   access = "Allow" },
        { name = "AllowAzureCloudOutbound",    priority = 110, direction = "Outbound", source = "*",                 dest = "AzureCloud",     port = "443",       protocol = "Tcp", access = "Allow" },
        { name = "AllowBastionHostCommOut",    priority = 120, direction = "Outbound", source = "VirtualNetwork",    dest = "VirtualNetwork", port = "8080,5701", protocol = "*",   access = "Allow" },
        { name = "AllowGetSessionInfoOut",     priority = 130, direction = "Outbound", source = "*",                 dest = "Internet",       port = "80",        protocol = "*",   access = "Allow" }
      ] : merge(r, { nsg_key = "hub_${env}_AzureBastionSubnet" })]
    ],

    [for env in ["prod", "nprod"] :
      [for r in [
        { name = "Allow-AzurePlatformDNS-In", priority = 100, direction = "Inbound", source = "168.63.129.16", dest = "*", port = "53", protocol = "*", access = "Allow" },
        { name = "Allow-Bastion-to-Mngt",     priority = 200, direction = "Inbound", source = "10.${env == "prod" ? "0" : "1"}.2.192/26", dest = "VirtualNetwork", port = "22,3389", protocol = "Tcp", access = "Allow" }
      ] : merge(r, { nsg_key = "hub_${env}_snet-hub-mngt-${env}-swe" })]
    ]
  ])

  hub_nsg_rules = { for rule in local.hub_nsg_rules_raw : "${rule.nsg_key}_${rule.name}" => rule }

  # Split por entorno real (prod = connectivity, nprod = production)
  hub_nsg_rules_prod  = { for k, v in local.hub_nsg_rules : k => v if length(regexall("_nprod_", v.nsg_key)) == 0 }
  hub_nsg_rules_nprod = { for k, v in local.hub_nsg_rules : k => v if length(regexall("_nprod_", v.nsg_key)) > 0 }

  # -----------------------------------------------------------------------
  # 2. REGLAS DATA-IA
  # -----------------------------------------------------------------------
  data_ai_nsg_rules_raw = flatten([
    [for env in ["prod", "nprod"] :
      [for r in [
        { name = "Allow-PE-Analytics-HTTPS", priority = 500, direction = "Inbound", source = "10.${env == "prod" ? "0" : "1"}.9.0/25", dest = "VirtualNetwork", port = "443",  protocol = "Tcp", access = "Allow" },
        { name = "Allow-PE-Analytics-SQL",   priority = 510, direction = "Inbound", source = "10.${env == "prod" ? "0" : "1"}.9.0/25", dest = "VirtualNetwork", port = "1433", protocol = "Tcp", access = "Allow" }
      ] : merge(r, { nsg_key = "dataai_${env}_snet-dataai-analytics-${env}-swe" })]
    ],

    [for env in ["prod", "nprod"] :
      [for r in [
        { name = "Allow-Analytics-to-Comp", priority = 500, direction = "Inbound", source = "10.${env == "prod" ? "0" : "1"}.8.128/25", dest = "VirtualNetwork", port = "443", protocol = "Tcp", access = "Allow" }
      ] : merge(r, { nsg_key = "dataai_${env}_snet-dataai-compute-${env}-swe" })]
    ]
  ])

  data_ai_nsg_rules = { for rule in local.data_ai_nsg_rules_raw : "${rule.nsg_key}_${rule.name}" => rule }

  # Split por entorno real (prod = data_ai, nprod = production)
  data_ai_nsg_rules_prod  = { for k, v in local.data_ai_nsg_rules : k => v if length(regexall("_nprod_", v.nsg_key)) == 0 }
  data_ai_nsg_rules_nprod = { for k, v in local.data_ai_nsg_rules : k => v if length(regexall("_nprod_", v.nsg_key)) > 0 }

  # -----------------------------------------------------------------------
  # 3. REGLAS AKS Y APPS
  # -----------------------------------------------------------------------
  prod_nsg_rules_raw = flatten([
    [for env in ["prod", "nprod"] :
      [for r in [
        { name = "Allow-Firewall-to-Ingress", priority = 300, direction = "Inbound", source = "10.${env == "prod" ? "0" : "1"}.2.0/26", dest = "VirtualNetwork", port = "443", protocol = "Tcp", access = "Allow" }
      ] : merge(r, { nsg_key = "aks_${env}_snet-aks-ingress-${env}-swe" })]
    ],

    [for env in ["prod", "nprod"] :
      [for r in [
        { name = "Allow-Firewall-to-ACA", priority = 400, direction = "Inbound", source = "10.${env == "prod" ? "0" : "1"}.2.0/26", dest = "VirtualNetwork", port = "443", protocol = "Tcp", access = "Allow" }
      ] : merge(r, { nsg_key = "apps_${env}_snet-apps-aca-${env}-swe" })]
    ]
  ])

  prod_nsg_rules = { for rule in local.prod_nsg_rules_raw : "${rule.nsg_key}_${rule.name}" => rule }
}

# =========================================================================
# DESPLIEGUE SEPARADO POR SUSCRIPCIÓN
# =========================================================================

resource "azurerm_network_security_rule" "hub_rules_prod" {
  provider = azurerm.connectivity
  for_each = local.hub_nsg_rules_prod

  name                        = each.value.name
  priority                    = each.value.priority
  direction                   = each.value.direction
  access                      = each.value.access
  protocol                    = each.value.protocol
  source_port_range           = "*"
  destination_port_range      = length(regexall(",", each.value.port)) > 0 ? null : each.value.port
  destination_port_ranges     = length(regexall(",", each.value.port)) > 0 ? split(",", each.value.port) : null
  source_address_prefix       = each.value.source
  destination_address_prefix  = each.value.dest

  resource_group_name         = azurerm_network_security_group.hub_nsgs_prod[each.value.nsg_key].resource_group_name
  network_security_group_name = azurerm_network_security_group.hub_nsgs_prod[each.value.nsg_key].name
}
/*
resource "azurerm_network_security_rule" "hub_rules_nprod" {
  provider = azurerm.production
  for_each = local.hub_nsg_rules_nprod

  name                        = each.value.name
  priority                    = each.value.priority
  direction                   = each.value.direction
  access                      = each.value.access
  protocol                    = each.value.protocol
  source_port_range           = "*"
  destination_port_range      = length(regexall(",", each.value.port)) > 0 ? null : each.value.port
  destination_port_ranges     = length(regexall(",", each.value.port)) > 0 ? split(",", each.value.port) : null
  source_address_prefix       = each.value.source
  destination_address_prefix  = each.value.dest

  resource_group_name         = azurerm_network_security_group.hub_nsgs_nprod[each.value.nsg_key].resource_group_name
  network_security_group_name = azurerm_network_security_group.hub_nsgs_nprod[each.value.nsg_key].name
}
*/
resource "azurerm_network_security_rule" "data_ai_rules_prod" {
  provider = azurerm.data_ai
  for_each = local.data_ai_nsg_rules_prod

  name                        = each.value.name
  priority                    = each.value.priority
  direction                   = each.value.direction
  access                      = each.value.access
  protocol                    = each.value.protocol
  source_port_range           = "*"
  destination_port_range      = length(regexall(",", each.value.port)) > 0 ? null : each.value.port
  destination_port_ranges     = length(regexall(",", each.value.port)) > 0 ? split(",", each.value.port) : null
  source_address_prefix       = each.value.source
  destination_address_prefix  = each.value.dest

  resource_group_name         = azurerm_network_security_group.data_nsgs_prod[each.value.nsg_key].resource_group_name
  network_security_group_name = azurerm_network_security_group.data_nsgs_prod[each.value.nsg_key].name
}
/*
resource "azurerm_network_security_rule" "data_ai_rules_nprod" {
  provider = azurerm.production
  for_each = local.data_ai_nsg_rules_nprod

  name                        = each.value.name
  priority                    = each.value.priority
  direction                   = each.value.direction
  access                      = each.value.access
  protocol                    = each.value.protocol
  source_port_range           = "*"
  destination_port_range      = length(regexall(",", each.value.port)) > 0 ? null : each.value.port
  destination_port_ranges     = length(regexall(",", each.value.port)) > 0 ? split(",", each.value.port) : null
  source_address_prefix       = each.value.source
  destination_address_prefix  = each.value.dest

  resource_group_name         = azurerm_network_security_group.data_nsgs_nprod[each.value.nsg_key].resource_group_name
  network_security_group_name = azurerm_network_security_group.data_nsgs_nprod[each.value.nsg_key].name
}
*/
resource "azurerm_network_security_rule" "prod_rules" {
  provider = azurerm.production
  for_each = local.prod_nsg_rules

  name                        = each.value.name
  priority                    = each.value.priority
  direction                   = each.value.direction
  access                      = each.value.access
  protocol                    = each.value.protocol
  source_port_range           = "*"
  destination_port_range      = length(regexall(",", each.value.port)) > 0 ? null : each.value.port
  destination_port_ranges     = length(regexall(",", each.value.port)) > 0 ? split(",", each.value.port) : null
  source_address_prefix       = each.value.source
  destination_address_prefix  = each.value.dest

  resource_group_name         = azurerm_network_security_group.prod_nsgs[each.value.nsg_key].resource_group_name
  network_security_group_name = azurerm_network_security_group.prod_nsgs[each.value.nsg_key].name
}