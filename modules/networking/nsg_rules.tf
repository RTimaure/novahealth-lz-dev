# Archivo: modules/networking/nsg_rules.tf

# =========================================================================
# MOTOR DINÁMICO DE REGLAS NSG (Matriz Multi-Entorno Prod & Non-Prod)
# =========================================================================

locals {
  # -----------------------------------------------------------------------
  # 1. REGLAS HUB (Conectividad - Incluyendo iteración para NProd)
  # -----------------------------------------------------------------------
  hub_nsg_rules_raw = flatten([
    # NSG: AppGatewaySubnet (Reglas obligatorias para AppGw v2 en ambos hubs)
    [for env in ["prod", "nprod"] : 
      [for r in [
        { name = "Allow-GatewayManager-In",  priority = 100, direction = "Inbound",  source = "GatewayManager",    dest = "*", port = "65200-65535", protocol = "Tcp", access = "Allow" },
        { name = "Allow-AzureLB-In",         priority = 110, direction = "Inbound",  source = "AzureLoadBalancer", dest = "*", port = "*",           protocol = "*",   access = "Allow" },
        { name = "Allow-Internet-HTTP-In",   priority = 120, direction = "Inbound",  source = "Internet",          dest = "*", port = "80,443",      protocol = "Tcp", access = "Allow" }
      ] : merge(r, { nsg_key = "hub_${env}-snet-hub-appgw-${env}-swe" })]
    ],
    
    # NSG: AzureBastionSubnet (Matriz estricta de 8 reglas en ambos hubs)
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
      ] : merge(r, { nsg_key = "hub_${env}-AzureBastionSubnet" })]
    ],

    # NSG: ManagementSubnet (Dinámico: ajusta IP del Bastion Origen según el hub)
    [for env in ["prod", "nprod"] : 
      [for r in [
        { name = "Allow-AzurePlatformDNS-In",priority = 100, direction = "Inbound",  source = "168.63.129.16",     dest = "*",              port = "53",          protocol = "*",   access = "Allow" },
        { name = "Allow-Bastion-to-Mngt",    priority = 200, direction = "Inbound",  source = "10.${env == "prod" ? "0" : "1"}.2.192/26", dest = "VirtualNetwork", port = "22,3389", protocol = "Tcp", access = "Allow" }
      ] : merge(r, { nsg_key = "hub_${env}-snet-hub-mngt-${env}-swe" })]
    ]
  ])
  
  hub_nsg_rules = { for rule in local.hub_nsg_rules_raw : "${rule.nsg_key}_${rule.name}" => rule }

  # -----------------------------------------------------------------------
  # 2. REGLAS DATA-IA (Data & IA Platform)
  # -----------------------------------------------------------------------
  data_ia_nsg_rules_raw = flatten([
    # NSG: AnalyticsSubnet (Dinámico: IP origen Datacompute Prod/Nprod)
    [for env in ["prod", "nprod"] : 
      [for r in [
        { name = "Allow-PE-Analytics-HTTPS", priority = 500, direction = "Inbound",  source = "10.${env == "prod" ? "0" : "1"}.9.0/25", dest = "VirtualNetwork", port = "443", protocol = "Tcp", access = "Allow" },
        { name = "Allow-PE-Analytics-SQL",   priority = 510, direction = "Inbound",  source = "10.${env == "prod" ? "0" : "1"}.9.0/25", dest = "VirtualNetwork", port = "1433", protocol = "Tcp", access = "Allow" }
      ] : merge(r, { nsg_key = "dataia_${env}-snet-dataia-analytics-${env}-swe" })]
    ],
    
    # NSG: DataComputeSubnet (Dinámico: IP origen Analytics Prod/Nprod)
    [for env in ["prod", "nprod"] : 
      [for r in [
        { name = "Allow-Analytics-to-Comp",  priority = 500, direction = "Inbound",  source = "10.${env == "prod" ? "0" : "1"}.8.128/25", dest = "VirtualNetwork", port = "443", protocol = "Tcp", access = "Allow" }
      ] : merge(r, { nsg_key = "dataia_${env}-snet-dataia-datacompute-${env}-swe" })]
    ]
  ])
  
  data_ia_nsg_rules = { for rule in local.data_ia_nsg_rules_raw : "${rule.nsg_key}_${rule.name}" => rule }

  # -----------------------------------------------------------------------
  # 3. REGLAS AKS Y APPS (Producción)
  # -----------------------------------------------------------------------
  prod_nsg_rules_raw = flatten([
    # NSG: AKSIngressSubnet (Dinámico: IP origen Firewall Prod/Nprod)
    [for env in ["prod", "nprod"] : 
      [for r in [
        { name = "Allow-Firewall-to-Ingress",priority = 300, direction = "Inbound",  source = "10.${env == "prod" ? "0" : "1"}.2.0/26", dest = "VirtualNetwork", port = "443", protocol = "Tcp", access = "Allow" }
      ] : merge(r, { nsg_key = "aks_${env}-snet-aks-ingress-${env}-swe" })]
    ],

    # NSG: ACASubnet (Dinámico: IP origen Firewall Prod/Nprod)
    [for env in ["prod", "nprod"] : 
      [for r in [
        { name = "Allow-Firewall-to-ACA",    priority = 400, direction = "Inbound",  source = "10.${env == "prod" ? "0" : "1"}.2.0/26", dest = "VirtualNetwork", port = "443", protocol = "Tcp", access = "Allow" }
      ] : merge(r, { nsg_key = "apps_${env}-snet-apps-aca-${env}-swe" })]
    ]
  ])
  
  prod_nsg_rules = { for rule in local.prod_nsg_rules_raw : "${rule.nsg_key}_${rule.name}" => rule }
}

# =========================================================================
# DESPLIEGUE SEPARADO POR SUSCRIPCIÓN (PROVIDERS)
# =========================================================================

resource "azurerm_network_security_rule" "hub_rules" {
  provider = azurerm.connectivity
  for_each = local.hub_nsg_rules

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

  resource_group_name         = azurerm_network_security_group.hub_nsgs[each.value.nsg_key].resource_group_name
  network_security_group_name = azurerm_network_security_group.hub_nsgs[each.value.nsg_key].name
}

resource "azurerm_network_security_rule" "data_ia_rules" {
  provider = azurerm.data_ia
  for_each = local.data_ia_nsg_rules

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

  resource_group_name         = azurerm_network_security_group.data_nsgs[each.value.nsg_key].resource_group_name
  network_security_group_name = azurerm_network_security_group.data_nsgs[each.value.nsg_key].name
}

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