# Archivo: modules/networking/main.tf

locals {
  fw_private_ip = "10.0.2.4"

  # =========================================================================
  # CAPA 1: ESTRUCTURA DE RED (11 VNets: Prod, Non-Prod y On-Premise)
  # =========================================================================
  vnets = {
    hub_prod = {
      name          = "vnet-hub-prod-swe-001"
      rg_name       = "rg-hub-prod-swe-001"
      location      = var.location
      address_space = ["10.0.0.0/22"]
      subnets = {
        "snet-hub-mngt-prod-swe"   = "10.0.0.0/24"
        "snet-hub-pe-prod-swe"     = "10.0.1.0/24"
        "AzureFirewallSubnet"      = "10.0.2.0/26"
        "snet-hub-appgw-prod-swe"  = "10.0.2.64/26"
        "GatewaySubnet"            = "10.0.2.128/26"
        "AzureBastionSubnet"       = "10.0.2.192/26"
        "snet-hub-DNSin-prod-swe"  = "10.0.3.0/27"
        "snet-hub-DNSout-prod-swe" = "10.0.3.32/27"
      }
    }
    aks_prod = {
      name          = "vnet-aks-prod-swe-001"
      rg_name       = "rg-aks-prod-swe-001"
      location      = var.location
      address_space = ["10.0.4.0/22"]
      subnets = {
        "snet-aks-workload-prod-swe"   = "10.0.4.0/23"
        "snet-aks-system-prod-swe"     = "10.0.6.0/24"
        "snet-aks-ingress-prod-swe"    = "10.0.7.0/26"
        "snet-aks-pe-prod-swe"         = "10.0.7.64/26"
        "snet-aks-monitoring-prod-swe" = "10.0.7.128/27"
      }
    }
    dataia_prod = {
      name          = "vnet-dataia-prod-swe-001"
      rg_name       = "rg-dataia-prod-swe-001"
      location      = var.location
      address_space = ["10.0.8.0/23"]
      subnets = {
        "snet-dataia-pe-prod-swe"          = "10.0.8.0/25"
        "snet-dataia-analytics-prod-swe"   = "10.0.8.128/25"
        "snet-dataia-datacompute-prod-swe" = "10.0.9.0/25"
        "snet-dataia-streamming-prod-swe"  = "10.0.9.128/26"
      }
    }
    apps_prod = {
      name          = "vnet-apps-prod-swe-001"
      rg_name       = "rg-apps-prod-swe-001"
      location      = var.location
      address_space = ["10.0.10.0/24"]
      subnets = {
        "snet-apps-aca-prod-swe"       = "10.0.10.0/25"
        "snet-apps-messaging-prod-swe" = "10.0.10.128/26"
        "snet-apps-pe-prod-swe"        = "10.0.10.192/26"
      }
    }
    shared_prod = {
      name          = "vnet-shared-prod-swe-001"
      rg_name       = "rg-shared-prod-swe-001"
      location      = var.location
      address_space = ["10.0.11.0/24"]
      subnets = {
        "snet-shared-pe-prod-swe"          = "10.0.11.0/25"
        "snet-shared-apim-prod-swe"        = "10.0.11.128/26"
        "snet-shared-devopstools-prod-swe" = "10.0.11.192/27"
      }
    }
    hub_nprod = {
      name          = "vnet-hub-nprod-swe-001"
      rg_name       = "rg-hub-nprod-swe-001"
      location      = var.location
      address_space = ["10.1.0.0/22"]
      subnets = {
        "snet-hub-mngt-nprod-swe"   = "10.1.0.0/24"
        "snet-hub-pe-nprod-swe"     = "10.1.1.0/24"
        "AzureFirewallSubnet"       = "10.1.2.0/26"
        "snet-hub-appgw-nprod-swe"  = "10.1.2.64/26"
        "GatewaySubnet"             = "10.1.2.128/26"
        "AzureBastionSubnet"        = "10.1.2.192/26"
        "snet-hub-DNSin-nprod-swe"  = "10.1.3.0/27"
        "snet-hub-DNSout-nprod-swe" = "10.1.3.32/27"
      }
    }
    aks_nprod = {
      name          = "vnet-aks-nprod-swe-001"
      rg_name       = "rg-aks-nprod-swe-001"
      location      = var.location
      address_space = ["10.1.4.0/22"]
      subnets = {
        "snet-aks-workload-nprod-swe"   = "10.1.4.0/23"
        "snet-aks-system-nprod-swe"     = "10.1.6.0/24"
        "snet-aks-ingress-nprod-swe"    = "10.1.7.0/26"
        "snet-aks-monitoring-nprod-swe" = "10.1.7.64/27"
        "snet-aks-pe-nprod-swe"         = "10.1.7.96/27"
      }
    }
    dataia_nprod = {
      name          = "vnet-dataia-nprod-swe-001"
      rg_name       = "rg-dataia-nprod-swe-001"
      location      = var.location
      address_space = ["10.1.8.0/23"]
      subnets = {
        "snet-dataia-pe-nprod-swe"          = "10.1.8.0/25"
        "snet-dataia-analytics-nprod-swe"   = "10.1.8.128/25"
        "snet-dataia-datacompute-nprod-swe" = "10.1.9.0/25"
        "snet-dataia-streamming-nprod-swe"  = "10.1.9.128/26"
      }
    }
    apps_nprod = {
      name          = "vnet-apps-nprod-swe-001"
      rg_name       = "rg-apps-nprod-swe-001"
      location      = var.location
      address_space = ["10.1.10.0/24"]
      subnets = {
        "snet-apps-aca-nprod-swe"       = "10.1.10.0/25"
        "snet-apps-messaging-nprod-swe" = "10.1.10.128/26"
        "snet-apps-pe-nprod-swe"        = "10.1.10.192/26"
      }
    }
    shared_nprod = {
      name          = "vnet-shared-nprod-swe-001"
      rg_name       = "rg-shared-nprod-swe-001"
      location      = var.location
      address_space = ["10.1.11.0/24"]
      subnets = {
        "snet-shared-pe-nprod-swe"          = "10.1.11.0/25"
        "snet-shared-apim-nprod-swe"        = "10.1.11.128/26"
        "snet-shared-devopstools-nprod-swe" = "10.1.11.192/27"
      }
    }
    onprem_prod = {
      name          = "vnet-onprem-prod-swe-001"
      rg_name       = "rg-onprem-prod-swe-001"
      location      = var.location
      address_space = ["172.16.0.0/16"]
      subnets = {
        "snet-onprem-users-prod-swe"    = "172.16.0.0/22"
        "snet-onprem-mngt-prod-swe"     = "172.16.4.0/24"
        "snet-onprem-servers-prod-swe"  = "172.16.5.0/24"
        "snet-onprem-dmz-prod-swe"      = "172.16.6.0/24"
        "snet-onprem-security-prod-swe" = "172.16.7.0/24"
        "snet-onprem-backup-prod-swe"   = "172.16.8.0/24"
        "GatewaySubnet"                 = "172.16.9.0/26"
      }
    }
  }

  subnet_list = flatten([
    for vkey, vnet in local.vnets : [
      for skey, scidr in vnet.subnets : {
        vnet_key    = vkey
        subnet_name = skey
        subnet_cidr = scidr
      }
    ]
  ])
  
  subnet_map = {
    for s in local.subnet_list : "${s.vnet_key}-${s.subnet_name}" => s
  }

  route_tables = {
    "rt-hubmngt-prod-swe-001" = { rg_key = "hub_prod" }
    "rt-aks-prod-swe-001"     = { rg_key = "aks_prod" }
    "rt-dataia-prod-swe-001"  = { rg_key = "dataia_prod" }
    "rt-shared-prod-swe-001"  = { rg_key = "shared_prod" }
    "rt-apps-prod-swe-001"    = { rg_key = "apps_prod" }
  }

  routes_config = flatten([
    for rt_name, rt_attr in local.route_tables : [
      { rt = rt_name, name = "udr-to-internet", prefix = "0.0.0.0/0", next_hop = "VirtualAppliance" },
      { rt = rt_name, name = "udr-to-hub", prefix = "10.0.0.0/22", next_hop = "VirtualAppliance" },
      { rt = rt_name, name = "udr-to-aks", prefix = "10.0.4.0/22", next_hop = "VirtualAppliance" },
      { rt = rt_name, name = "udr-to-dataia", prefix = "10.0.8.0/23", next_hop = "VirtualAppliance" },
      { rt = rt_name, name = "udr-to-apps", prefix = "10.0.10.0/24", next_hop = "VirtualAppliance" },
      { rt = rt_name, name = "udr-to-shared", prefix = "10.0.11.0/24", next_hop = "VirtualAppliance" }
    ]
  ])

  routes_map = { for r in local.routes_config : "${r.rt}-${r.name}" => r }

  # =========================================================================
  # CLASIFICACIÓN DINÁMICA MULTI-SUSCRIPCIÓN (Incluye Regex para On-Premise)
  # =========================================================================
  hub_vnets    = { for k, v in local.vnets : k => v if length(regexall("^(hub|onprem)", k)) > 0 }
  data_vnets   = { for k, v in local.vnets : k => v if length(regexall("^dataia", k)) > 0 }
  prod_vnets   = { for k, v in local.vnets : k => v if length(regexall("^(aks|apps|shared)", k)) > 0 }

  hub_subnets  = { for k, v in local.subnet_map : k => v if length(regexall("^(hub|onprem)", v.vnet_key)) > 0 }
  data_subnets = { for k, v in local.subnet_map : k => v if length(regexall("^dataia", v.vnet_key)) > 0 }
  prod_subnets = { for k, v in local.subnet_map : k => v if length(regexall("^(aks|apps|shared)", v.vnet_key)) > 0 }
}

# =========================================================================
# CAPA 1 & 3: DOMINIO HUB Y ON-PREMISE (SUSCRIPCIÓN: CONNECTIVITY)
# =========================================================================
resource "azurerm_resource_group" "hub" {
  provider = azurerm.connectivity
  for_each = local.hub_vnets
  name     = each.value.rg_name
  location = each.value.location
  tags     = var.tags
}

resource "azurerm_virtual_network" "hub" {
  provider            = azurerm.connectivity
  for_each            = local.hub_vnets
  name                = each.value.name
  location            = each.value.location
  resource_group_name = azurerm_resource_group.hub[each.key].name
  address_space       = each.value.address_space
  tags                = var.tags
}

resource "azurerm_subnet" "hub" {
  provider             = azurerm.connectivity
  for_each             = local.hub_subnets
  name                 = each.value.subnet_name
  resource_group_name  = azurerm_resource_group.hub[each.value.vnet_key].name
  virtual_network_name = azurerm_virtual_network.hub[each.value.vnet_key].name
  address_prefixes     = [each.value.subnet_cidr]

  dynamic "delegation" {
    for_each = length(regexall("DNSin|DNSout", each.value.subnet_name)) > 0 ? [1] : []
    content {
      name = "Microsoft.Network.dnsResolvers"
      service_delegation {
        name    = "Microsoft.Network/dnsResolvers"
        actions = ["Microsoft.Network/virtualNetworks/subnets/join/action"]
      }
    }
  }
}

resource "azurerm_network_security_group" "hub_nsgs" {
  provider            = azurerm.connectivity
  for_each            = { for k, v in local.hub_subnets : k => v if !contains(["AzureFirewallSubnet", "GatewaySubnet"], v.subnet_name) }
  name                = length(regexall("^snet-", each.value.subnet_name)) > 0 ? "nsg-${split("-", each.value.subnet_name)[1]}${split("-", each.value.subnet_name)[2]}-${split("-", each.value.subnet_name)[3]}-${split("-", each.value.subnet_name)[4]}-001" : "nsg-${lower(each.value.subnet_name)}-${length(regexall("nprod", each.value.vnet_key)) > 0 ? "nprod" : "prod"}-swe-001"
  location            = var.location
  resource_group_name = azurerm_resource_group.hub[each.value.vnet_key].name
  tags                = var.tags
}

resource "azurerm_subnet_network_security_group_association" "hub" {
  provider                  = azurerm.connectivity
  for_each                  = azurerm_network_security_group.hub_nsgs
  subnet_id                 = azurerm_subnet.hub[each.key].id
  network_security_group_id = each.value.id

  depends_on = [
    azurerm_network_security_rule.hub_rules
  ]
}

# =========================================================================
# CAPA 1 & 3: DOMINIO DATA & IA (SUSCRIPCIÓN: DATA AND IA PLATFORM)
# =========================================================================
resource "azurerm_resource_group" "data" {
  provider = azurerm.data_ia
  for_each = local.data_vnets
  name     = each.value.rg_name
  location = each.value.location
  tags     = var.tags
}

resource "azurerm_virtual_network" "data" {
  provider            = azurerm.data_ia
  for_each            = local.data_vnets
  name                = each.value.name
  location            = each.value.location
  resource_group_name = azurerm_resource_group.data[each.key].name
  address_space       = each.value.address_space
  tags                = var.tags
}

resource "azurerm_subnet" "data" {
  provider             = azurerm.data_ia
  for_each             = local.data_subnets
  name                 = each.value.subnet_name
  resource_group_name  = azurerm_resource_group.data[each.value.vnet_key].name
  virtual_network_name = azurerm_virtual_network.data[each.value.vnet_key].name
  address_prefixes     = [each.value.subnet_cidr]
}

resource "azurerm_network_security_group" "data_nsgs" {
  provider            = azurerm.data_ia
  for_each            = local.data_subnets
  name                = length(regexall("^snet-", each.value.subnet_name)) > 0 ? "nsg-${split("-", each.value.subnet_name)[1]}${split("-", each.value.subnet_name)[2]}-${split("-", each.value.subnet_name)[3]}-${split("-", each.value.subnet_name)[4]}-001" : "nsg-${lower(each.value.subnet_name)}-${length(regexall("nprod", each.value.vnet_key)) > 0 ? "nprod" : "prod"}-swe-001"
  location            = var.location
  resource_group_name = azurerm_resource_group.data[each.value.vnet_key].name
  tags                = var.tags
}

resource "azurerm_subnet_network_security_group_association" "data" {
  provider                  = azurerm.data_ia
  for_each                  = azurerm_network_security_group.data_nsgs
  subnet_id                 = azurerm_subnet.data[each.key].id
  network_security_group_id = each.value.id

  depends_on = [
    azurerm_network_security_rule.data_ia_rules
  ]
}

# =========================================================================
# CAPA 1 & 3: DOMINIO PRODUCCIÓN (SUSCRIPCIÓN: PRODUCTION)
# =========================================================================
resource "azurerm_resource_group" "prod" {
  provider = azurerm.production
  for_each = local.prod_vnets
  name     = each.value.rg_name
  location = each.value.location
  tags     = var.tags
}

resource "azurerm_virtual_network" "prod" {
  provider            = azurerm.production
  for_each            = local.prod_vnets
  name                = each.value.name
  location            = each.value.location
  resource_group_name = azurerm_resource_group.prod[each.key].name
  address_space       = each.value.address_space
  tags                = var.tags
}

resource "azurerm_subnet" "prod" {
  provider             = azurerm.production
  for_each             = local.prod_subnets
  name                 = each.value.subnet_name
  resource_group_name  = azurerm_resource_group.prod[each.value.vnet_key].name
  virtual_network_name = azurerm_virtual_network.prod[each.value.vnet_key].name
  address_prefixes     = [each.value.subnet_cidr]
}

resource "azurerm_network_security_group" "prod_nsgs" {
  provider            = azurerm.production
  for_each            = local.prod_subnets
  name                = length(regexall("^snet-", each.value.subnet_name)) > 0 ? "nsg-${split("-", each.value.subnet_name)[1]}${split("-", each.value.subnet_name)[2]}-${split("-", each.value.subnet_name)[3]}-${split("-", each.value.subnet_name)[4]}-001" : "nsg-${lower(each.value.subnet_name)}-${length(regexall("nprod", each.value.vnet_key)) > 0 ? "nprod" : "prod"}-swe-001"
  location            = var.location
  resource_group_name = azurerm_resource_group.prod[each.value.vnet_key].name
  tags                = var.tags
}

resource "azurerm_subnet_network_security_group_association" "prod" {
  provider                  = azurerm.production
  for_each                  = azurerm_network_security_group.prod_nsgs
  subnet_id                 = azurerm_subnet.prod[each.key].id
  network_security_group_id = each.value.id

  depends_on = [
    azurerm_network_security_rule.prod_rules
  ]
}

# =========================================================================
# GLOBAL VNET PEERINGS (Routing adaptativo Prod/Non-Prod a su respectivo Hub)
# =========================================================================
resource "azurerm_virtual_network_peering" "hub_to_prod" {
  provider                     = azurerm.connectivity
  for_each                     = local.prod_vnets
  name                         = "peer-hub-to-${each.key}-swe-01"
  resource_group_name          = azurerm_resource_group.hub[length(regexall("nprod", each.key)) > 0 ? "hub_nprod" : "hub_prod"].name
  virtual_network_name         = azurerm_virtual_network.hub[length(regexall("nprod", each.key)) > 0 ? "hub_nprod" : "hub_prod"].name
  remote_virtual_network_id    = azurerm_virtual_network.prod[each.key].id
  allow_virtual_network_access = true
  allow_forwarded_traffic      = true
  depends_on                   = [azurerm_subnet.hub, azurerm_subnet.prod]
}

resource "azurerm_virtual_network_peering" "prod_to_hub" {
  provider                     = azurerm.production
  for_each                     = local.prod_vnets
  name                         = "peer-${each.key}-to-hub-swe-01"
  resource_group_name          = azurerm_resource_group.prod[each.key].name
  virtual_network_name         = azurerm_virtual_network.prod[each.key].name
  remote_virtual_network_id    = azurerm_virtual_network.hub[length(regexall("nprod", each.key)) > 0 ? "hub_nprod" : "hub_prod"].id
  allow_virtual_network_access = true
  allow_forwarded_traffic      = true
  depends_on                   = [azurerm_subnet.prod, azurerm_subnet.hub]
}

resource "azurerm_virtual_network_peering" "hub_to_data" {
  provider                     = azurerm.connectivity
  for_each                     = local.data_vnets
  name                         = "peer-hub-to-${each.key}-swe-01"
  resource_group_name          = azurerm_resource_group.hub[length(regexall("nprod", each.key)) > 0 ? "hub_nprod" : "hub_prod"].name
  virtual_network_name         = azurerm_virtual_network.hub[length(regexall("nprod", each.key)) > 0 ? "hub_nprod" : "hub_prod"].name
  remote_virtual_network_id    = azurerm_virtual_network.data[each.key].id
  allow_virtual_network_access = true
  allow_forwarded_traffic      = true
  depends_on                   = [azurerm_subnet.hub, azurerm_subnet.data]
}

resource "azurerm_virtual_network_peering" "data_to_hub" {
  provider                     = azurerm.data_ia
  for_each                     = local.data_vnets
  name                         = "peer-${each.key}-to-hub-swe-01"
  resource_group_name          = azurerm_resource_group.data[each.key].name
  virtual_network_name         = azurerm_virtual_network.data[each.key].name
  remote_virtual_network_id    = azurerm_virtual_network.hub[length(regexall("nprod", each.key)) > 0 ? "hub_nprod" : "hub_prod"].id
  allow_virtual_network_access = true
  allow_forwarded_traffic      = true
  depends_on                   = [azurerm_subnet.data, azurerm_subnet.hub]
}

# =========================================================================
# CAPA 2: APPLIANCES PERIMETRALES (Solo para Entorno PROD por ahorros FinOps)
# =========================================================================
resource "azurerm_public_ip" "firewall_pip" {
  provider            = azurerm.connectivity
  name                = "pip-fw-prod-swe-001"
  location            = var.location
  resource_group_name = azurerm_resource_group.hub["hub_prod"].name
  allocation_method   = "Static"
  sku                 = "Standard"
  tags                = var.tags
}

resource "azurerm_firewall_policy" "fw_policy" {
  provider            = azurerm.connectivity
  name                = "afwp-hub-prod-swe-001"
  resource_group_name = azurerm_resource_group.hub["hub_prod"].name
  location            = var.location
  tags                = var.tags
}

resource "azurerm_firewall" "fw" {
  provider            = azurerm.connectivity
  name                = "afw-hub-prod-swe-001"
  location            = var.location
  resource_group_name = azurerm_resource_group.hub["hub_prod"].name
  sku_name            = "AZFW_VNet"
  sku_tier            = "Standard"
  firewall_policy_id  = azurerm_firewall_policy.fw_policy.id
  tags                = var.tags

  ip_configuration {
    name                 = "configuration"
    subnet_id            = azurerm_subnet.hub["hub_prod-AzureFirewallSubnet"].id
    public_ip_address_id = azurerm_public_ip.firewall_pip.id
  }
}

resource "azurerm_public_ip" "bastion_pip" {
  provider            = azurerm.connectivity
  name                = "pip-bas-prod-swe-001"
  location            = var.location
  resource_group_name = azurerm_resource_group.hub["hub_prod"].name
  allocation_method   = "Static"
  sku                 = "Standard"
  tags                = var.tags
}

resource "azurerm_bastion_host" "bastion" {
  provider            = azurerm.connectivity
  name                = "bas-hub-prod-swe-001"
  location            = var.location
  resource_group_name = azurerm_resource_group.hub["hub_prod"].name
  sku                 = "Standard"
  tags                = var.tags

  ip_configuration {
    name                 = "configuration"
    subnet_id            = azurerm_subnet.hub["hub_prod-AzureBastionSubnet"].id
    public_ip_address_id = azurerm_public_ip.bastion_pip.id
  }
  timeouts {
    create = "45m"
  }
}

resource "azurerm_public_ip" "vpngw_pip" {
  provider            = azurerm.connectivity
  name                = "pip-vpngw-prod-swe-001"
  location            = var.location
  resource_group_name = azurerm_resource_group.hub["hub_prod"].name
  allocation_method   = "Static"
  sku                 = "Standard"
  zones               = ["1", "2", "3"]
  tags                = var.tags
}

# =========================================================================
# CAPA 4: APPLICATION GATEWAY (Solo para Entorno PROD por ahorros FinOps)
# =========================================================================
resource "azurerm_public_ip" "appgw_pip" {
  provider            = azurerm.connectivity
  name                = "pip-appgw-prod-swe-001"
  location            = var.location
  resource_group_name = azurerm_resource_group.hub["hub_prod"].name
  allocation_method   = "Static"
  sku                 = "Standard"
  tags                = var.tags
}

resource "azurerm_web_application_firewall_policy" "waf" {
  provider            = azurerm.connectivity
  name                = "waf-agw-prod-swe-001"
  resource_group_name = azurerm_resource_group.hub["hub_prod"].name
  location            = var.location
  tags                = var.tags

  policy_settings {
    enabled                     = true
    mode                        = "Prevention"
    request_body_check          = true
    file_upload_limit_in_mb     = 100
    max_request_body_size_in_kb = 128
  }

  managed_rules {
    managed_rule_set {
      type    = "OWASP"
      version = "3.2"
    }
  }
}

resource "azurerm_application_gateway" "appgw" {
  provider            = azurerm.connectivity
  name                = "agw-hub-prod-swe-001"
  resource_group_name = azurerm_resource_group.hub["hub_prod"].name
  location            = var.location
  tags                = var.tags
  firewall_policy_id  = azurerm_web_application_firewall_policy.waf.id

  sku {
    name     = "WAF_v2"
    tier     = "WAF_v2"
    capacity = 2
  }

  ssl_policy {
    policy_type = "Predefined"
    policy_name = "AppGwSslPolicy20220101"
  }

  gateway_ip_configuration {
    name      = "agw-ip-config"
    subnet_id = azurerm_subnet.hub["hub_prod-snet-hub-appgw-prod-swe"].id
  }

  frontend_port {
    name = "frontend-port-http"
    port = 80
  }

  frontend_ip_configuration {
    name                 = "frontend-ip-config"
    public_ip_address_id = azurerm_public_ip.appgw_pip.id
  }

  backend_address_pool {
    name = "backend-pool"
  }

  backend_http_settings {
    name                  = "backend-http-settings"
    cookie_based_affinity = "Disabled"
    port                  = 80
    protocol              = "Http"
    request_timeout       = 60
  }

  http_listener {
    name                           = "http-listener"
    frontend_ip_configuration_name = "frontend-ip-config"
    frontend_port_name             = "frontend-port-http"
    protocol                       = "Http"
  }

  request_routing_rule {
    name                       = "routing-rule"
    priority                   = 100
    rule_type                  = "Basic"
    http_listener_name         = "http-listener"
    backend_address_pool_name  = "backend-pool"
    backend_http_settings_name = "backend-http-settings"
  }
}