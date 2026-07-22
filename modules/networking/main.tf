# Archivo: modules/networking/main.tf

terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.90.0"
    }
  }
}

locals {
  # IP Privada del Firewall para inspección de tráfico
  fw_private_ip = "10.0.2.4"

  # =========================================================================
  # CAPA 1: ESTRUCTURA DE RED (VNets, Subnets, Peerings, UDRs)
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

  subnet_udr_associations = {
    "hub_prod-snet-hub-mngt-prod-swe"              = "rt-hubmngt-prod-swe-001"
    "aks_prod-snet-aks-workload-prod-swe"          = "rt-aks-prod-swe-001"
    "aks_prod-snet-aks-system-prod-swe"            = "rt-aks-prod-swe-001"
    "aks_prod-snet-aks-ingress-prod-swe"           = "rt-aks-prod-swe-001"
    "dataia_prod-snet-dataia-analytics-prod-swe"   = "rt-dataia-prod-swe-001"
    "dataia_prod-snet-dataia-datacompute-prod-swe" = "rt-dataia-prod-swe-001"
    "dataia_prod-snet-dataia-streamming-prod-swe"  = "rt-dataia-prod-swe-001"
    "shared_prod-snet-shared-apim-prod-swe"        = "rt-shared-prod-swe-001"
    "shared_prod-snet-shared-devopstools-prod-swe" = "rt-shared-prod-swe-001"
    "apps_prod-snet-apps-aca-prod-swe"             = "rt-apps-prod-swe-001"
    "apps_prod-snet-apps-messaging-prod-swe"       = "rt-apps-prod-swe-001"
  }

  peerings = {
    "peer-hub-aks-prod-swe-01"    = { src = "hub_prod", dst = "aks_prod", fwd = true, gw_transit = false, use_remote = false }
    "peer-aks-hub-prod-swe-01"    = { src = "aks_prod", dst = "hub_prod", fwd = true, gw_transit = false, use_remote = false }
    "peer-hub-dataia-prod-swe-01" = { src = "hub_prod", dst = "dataia_prod", fwd = true, gw_transit = false, use_remote = false }
    "peer-dataia-hub-prod-swe-01" = { src = "dataia_prod", dst = "hub_prod", fwd = true, gw_transit = false, use_remote = false }
    "peer-hub-apps-prod-swe-01"   = { src = "hub_prod", dst = "apps_prod", fwd = true, gw_transit = false, use_remote = false }
    "peer-apps-hub-prod-swe-01"   = { src = "apps_prod", dst = "hub_prod", fwd = true, gw_transit = false, use_remote = false }
    "peer-hub-shared-prod-swe-01" = { src = "hub_prod", dst = "shared_prod", fwd = true, gw_transit = false, use_remote = false }
    "peer-shared-hub-prod-swe-01" = { src = "shared_prod", dst = "hub_prod", fwd = true, gw_transit = false, use_remote = false }
  }
}

# --- RECURSOS CAPA 1 ---
resource "azurerm_resource_group" "net_rg" {
  for_each = local.vnets
  name     = each.value.rg_name
  location = each.value.location
  tags     = var.tags
}

resource "azurerm_virtual_network" "vnet" {
  for_each            = local.vnets
  name                = each.value.name
  location            = azurerm_resource_group.net_rg[each.key].location
  resource_group_name = azurerm_resource_group.net_rg[each.key].name
  address_space       = each.value.address_space
  tags                = var.tags
  depends_on          = [azurerm_resource_group.net_rg]
}

/*
resource "azurerm_subnet" "subnet" {
  for_each             = local.subnet_map
  name                 = each.value.subnet_name
  resource_group_name  = azurerm_resource_group.net_rg[each.value.vnet_key].name
  virtual_network_name = azurerm_virtual_network.vnet[each.value.vnet_key].name
  address_prefixes     = [each.value.subnet_cidr]
  depends_on           = [azurerm_virtual_network.vnet]
}
*/

resource "azurerm_subnet" "subnet" {
  for_each             = local.subnet_map
  name                 = each.value.subnet_name
  resource_group_name  = azurerm_resource_group.net_rg[each.value.vnet_key].name
  virtual_network_name = azurerm_virtual_network.vnet[each.value.vnet_key].name
  address_prefixes     = [each.value.subnet_cidr]

  # Inyección dinámica de delegación solo para subredes de DNS Resolver
  dynamic "delegation" {
    for_each = can(regex("DNSin|DNSout", each.value.subnet_name)) ? [1] : []
    content {
      name = "dns-resolver-delegation"
      service_delegation {
        name    = "Microsoft.Network/dnsResolvers"
        actions = ["Microsoft.Network/virtualNetworks/subnets/join/action"]
      }
    }
  }

  depends_on = [azurerm_virtual_network.vnet]
}

resource "azurerm_route_table" "udr" {
  for_each                      = local.route_tables
  name                          = each.key
  location                      = var.location
  resource_group_name           = azurerm_resource_group.net_rg[each.value.rg_key].name
  disable_bgp_route_propagation = false
  tags                          = var.tags
  depends_on                    = [azurerm_resource_group.net_rg]
}

resource "azurerm_route" "routes" {
  for_each               = local.routes_map
  name                   = each.value.name
  resource_group_name    = azurerm_route_table.udr[each.value.rt].resource_group_name
  route_table_name       = azurerm_route_table.udr[each.value.rt].name
  address_prefix         = each.value.prefix
  next_hop_type          = each.value.next_hop
  next_hop_in_ip_address = each.value.next_hop == "VirtualAppliance" ? local.fw_private_ip : null
  depends_on             = [azurerm_route_table.udr]
}

resource "azurerm_subnet_route_table_association" "udr_assoc" {
  for_each       = local.subnet_udr_associations
  subnet_id      = azurerm_subnet.subnet[each.key].id
  route_table_id = azurerm_route_table.udr[each.value].id
  depends_on     = [azurerm_subnet.subnet, azurerm_route_table.udr, azurerm_route.routes]
}

resource "azurerm_virtual_network_peering" "peerings" {
  for_each                     = local.peerings
  name                         = each.key
  resource_group_name          = azurerm_virtual_network.vnet[each.value.src].resource_group_name
  virtual_network_name         = azurerm_virtual_network.vnet[each.value.src].name
  remote_virtual_network_id    = azurerm_virtual_network.vnet[each.value.dst].id
  allow_virtual_network_access = true
  allow_forwarded_traffic      = each.value.fwd
  allow_gateway_transit        = each.value.gw_transit
  use_remote_gateways          = each.value.use_remote
  depends_on                   = [azurerm_virtual_network.vnet]
}

# =========================================================================
# CAPA 3: POLÍTICAS DE FIREWALL Y NSGs (SEGURIDAD PERIMETRAL Y ZONAS)
# (Se inyecta antes de la Capa 2 para que el FW pueda consumirla al nacer)
# =========================================================================

# 1. NSGs (Network Security Groups)
resource "azurerm_network_security_group" "nsg" {
  for_each            = local.vnets
  name                = "nsg-${split("_", each.key)[0]}-${split("_", each.key)[1]}-swe-001"
  location            = each.value.location
  resource_group_name = each.value.rg_name
  tags                = var.tags
  depends_on          = [azurerm_resource_group.net_rg]
}

# 2. Asociaciones de NSG dinámicas
locals {
  nsg_associations = {
    for k, v in local.subnet_map : k => v
    if !contains(["AzureFirewallSubnet", "GatewaySubnet", "AzureBastionSubnet"], v.subnet_name) && !can(regex("appgw", v.subnet_name))
  }
}

resource "azurerm_subnet_network_security_group_association" "nsg_assoc" {
  for_each                  = local.nsg_associations
  subnet_id                 = azurerm_subnet.subnet[each.key].id
  network_security_group_id = azurerm_network_security_group.nsg[each.value.vnet_key].id
  depends_on                = [azurerm_subnet.subnet, azurerm_network_security_group.nsg]
}

# 3. Azure Firewall Policy
resource "azurerm_firewall_policy" "fw_policy" {
  name                = "afwp-hub-prod-swe-001"
  resource_group_name = azurerm_resource_group.net_rg["hub_prod"].name
  location            = var.location
  tags                = var.tags
  
  dns {
    proxy_enabled = true
  }
  depends_on = [azurerm_resource_group.net_rg]
}

# 4. Azure Firewall Rules
resource "azurerm_firewall_policy_rule_collection_group" "fw_rules" {
  name               = "afwpr-hub-prod-swe-001"
  firewall_policy_id = azurerm_firewall_policy.fw_policy.id
  priority           = 100

  network_rule_collection {
    name     = "Network-Rules-Core"
    priority = 200
    action   = "Allow"

    rule {
      name                  = "Allow-AKS-to-AzureMonitor"
      protocols             = ["TCP"]
      source_addresses      = ["10.0.4.0/22", "10.1.4.0/22"]
      destination_addresses = ["AzureMonitor"]
      destination_ports     = ["443"]
    }
    
    rule {
      name                  = "Allow-Bastion-to-Spokes-RDP-SSH"
      protocols             = ["TCP"]
      source_addresses      = ["10.0.2.192/26", "10.1.2.192/26"]
      destination_addresses = ["10.0.0.0/8"]
      destination_ports     = ["22", "3389"]
    }
    
    rule {
      name                  = "Allow-Internal-East-West"
      protocols             = ["TCP", "UDP"]
      source_addresses      = ["10.0.0.0/8"]
      destination_addresses = ["10.0.0.0/8"]
      destination_ports     = ["443", "1433", "5671", "80"]
    }
  }

  application_rule_collection {
    name     = "Application-Rules-Internet"
    priority = 300
    action   = "Allow"

    rule {
      name = "Allow-AKS-Internet-Egress"
      protocols {
        type = "Https"
        port = 443
      }
      protocols {
        type = "Http"
        port = 80
      }
      source_addresses  = ["10.0.4.0/22", "10.1.4.0/22"]
      destination_fqdns = [
        "*.github.com",
        "*.docker.io",
        "mcr.microsoft.com",
        "*.ubuntu.com",
        "*.azure.com",
        "*.azure.net"
      ]
    }
    
    rule {
      name = "Allow-Apps-to-PaaS"
      protocols {
        type = "Https"
        port = 443
      }
      source_addresses  = ["10.0.0.0/8"]
      destination_fqdns = [
        "*.database.windows.net",
        "*.blob.core.windows.net",
        "*.vault.azure.net",
        "*.search.windows.net",
        "*.openai.azure.com"
      ]
    }
  }
}

# =========================================================================
# CAPA 2: APPLIANCES PERIMETRALES (FIREWALL & BASTION)
# =========================================================================
resource "azurerm_public_ip" "fw_pip" {
  name                = "pip-fw-prod-swe-001"
  location            = var.location
  resource_group_name = azurerm_resource_group.net_rg["hub_prod"].name
  allocation_method   = "Static"
  sku                 = "Standard"
  tags                = var.tags
  depends_on          = [azurerm_resource_group.net_rg]
}

resource "azurerm_firewall" "fw" {
  name                = "afw-hub-prod-swe-001"
  location            = var.location
  resource_group_name = azurerm_resource_group.net_rg["hub_prod"].name
  sku_name            = "AZFW_VNet"
  sku_tier            = "Standard"
  tags                = var.tags
  firewall_policy_id  = azurerm_firewall_policy.fw_policy.id

  ip_configuration {
    name                 = "fw-ip-config"
    subnet_id            = azurerm_subnet.subnet["hub_prod-AzureFirewallSubnet"].id
    public_ip_address_id = azurerm_public_ip.fw_pip.id
  }

  depends_on = [
    azurerm_subnet.subnet,
    azurerm_public_ip.fw_pip,
    azurerm_firewall_policy.fw_policy
  ]
}

resource "azurerm_public_ip" "bastion_pip" {
  name                = "pip-bas-prod-swe-001"
  location            = var.location
  resource_group_name = azurerm_resource_group.net_rg["hub_prod"].name
  allocation_method   = "Static"
  sku                 = "Standard"
  tags                = var.tags
  depends_on          = [azurerm_resource_group.net_rg]
}

resource "azurerm_bastion_host" "bastion" {
  name                = "bas-hub-prod-swe-001"
  location            = var.location
  resource_group_name = azurerm_resource_group.net_rg["hub_prod"].name
  sku                 = "Standard"
  tags                = var.tags

  ip_configuration {
    name                 = "bastion-ip-config"
    subnet_id            = azurerm_subnet.subnet["hub_prod-AzureBastionSubnet"].id
    public_ip_address_id = azurerm_public_ip.bastion_pip.id
  }

  depends_on = [
    azurerm_subnet.subnet,
    azurerm_public_ip.bastion_pip
  ]
}

# Archivo: modules/networking/main.tf

# =========================================================================
# CAPA 4: SERVICIOS PERIMETRALES AVANZADOS (WAF, VPN & DNS)
# Según matriz de diseño networking_hub_spoke.csv (Flujos F1, F3, F4)
# =========================================================================

# -------------------------------------------------------------------------
# 1. APPLICATION GATEWAY WAF v2 (Flujo F1 - Publicación Segura)
# -------------------------------------------------------------------------
resource "azurerm_public_ip" "appgw_pip" {
  name                = "pip-agw-prod-swe-001"
  location            = var.location
  resource_group_name = azurerm_resource_group.net_rg["hub_prod"].name
  allocation_method   = "Static"
  sku                 = "Standard"
  tags                = var.tags
  depends_on          = [azurerm_resource_group.net_rg]
}

# NUEVO RECURSO: WAF Policy Independiente (Reemplaza configuración deprecada)
resource "azurerm_web_application_firewall_policy" "waf_policy" {
  name                = "waf-agw-prod-swe-001"
  resource_group_name = azurerm_resource_group.net_rg["hub_prod"].name
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
  
  depends_on = [azurerm_resource_group.net_rg]
}

resource "azurerm_application_gateway" "appgw" {
  name                = "agw-hub-prod-swe-001"
  location            = var.location
  resource_group_name = azurerm_resource_group.net_rg["hub_prod"].name
  tags                = var.tags
  
  # Asociación de la nueva política WAF independiente
  firewall_policy_id = azurerm_web_application_firewall_policy.waf_policy.id

  sku {
    name     = "WAF_v2"
    tier     = "WAF_v2"
    capacity = 2
  }

  # SOLUCIÓN AL ERROR: Forzar uso exclusivo de TLS 1.2 y TLS 1.3
  ssl_policy {
    policy_type = "Predefined"
    policy_name = "AppGwSslPolicy20220101"
  }

  gateway_ip_configuration {
    name      = "appgw-ip-config"
    subnet_id = azurerm_subnet.subnet["hub_prod-snet-hub-appgw-prod-swe"].id
  }

  frontend_port {
    name = "fe-port-https"
    port = 443
  }
  
  frontend_port {
    name = "fe-port-http"
    port = 80
  }

  frontend_ip_configuration {
    name                 = "fe-ip-config"
    public_ip_address_id = azurerm_public_ip.appgw_pip.id
  }

  backend_address_pool {
    name = "aks-backend-pool"
  }

  backend_http_settings {
    name                  = "https-settings"
    cookie_based_affinity = "Disabled"
    port                  = 443
    protocol              = "Https"
    request_timeout       = 60
  }

  http_listener {
    name                           = "http-listener"
    frontend_ip_configuration_name = "fe-ip-config"
    frontend_port_name             = "fe-port-http"
    protocol                       = "Http"
  }

  request_routing_rule {
    name                       = "rule-aks-routing"
    rule_type                  = "Basic"
    http_listener_name         = "http-listener"
    backend_address_pool_name  = "aks-backend-pool"
    backend_http_settings_name = "https-settings"
    priority                   = 100
  }

  # Nota: Se eliminaron dependencias explícitas redundantes ya resueltas por referencias internas (.id)
  depends_on = [
    azurerm_subnet.subnet
  ]
}


# -------------------------------------------------------------------------
# 2. AZURE VIRTUAL NETWORK GATEWAY (Flujo F3 - VPN IPSec BGP)
# [COMENTADO TEMPORALMENTE] Motivo: Límite estricto de 3 IPs Públicas por
# región alcanzado (Firewall, Bastion, AppGW). El SKU también ha sido 
# actualizado a 'VpnGw1AZ' para cumplir con las nuevas normativas de ARM.
# -------------------------------------------------------------------------

# ESTA PARTE DE PUNTO 2 SE COMENTA PARA EVITAR ERRORES DE LÍMITE DE IP PÚBLICAS EN LA REGIÓN - EN CUENTA PAY AS YOU GO DESCOMENTAR
resource "azurerm_public_ip" "vpngw_pip" {
  name                = "pip-vpn-prod-swe-001"
  location            = var.location
  resource_group_name = azurerm_resource_group.net_rg["hub_prod"].name
  allocation_method   = "Static"
  sku                 = "Standard"
  tags                = var.tags
  depends_on          = [azurerm_resource_group.net_rg]
}

resource "azurerm_virtual_network_gateway" "vpngw" {
  name                = "vgw-hub-prod-swe-001"
  location            = var.location
  resource_group_name = azurerm_resource_group.net_rg["hub_prod"].name
  type                = "Vpn"
  vpn_type            = "RouteBased"
  active_active       = false
  enable_bgp          = true
  sku                 = "VpnGw1AZ" # Corregido desde VpnGw1 clásico
  tags                = var.tags

  ip_configuration {
    name                          = "vpngw-ip-config"
    public_ip_address_id          = azurerm_public_ip.vpngw_pip.id
    private_ip_address_allocation = "Dynamic"
    subnet_id                     = azurerm_subnet.subnet["hub_prod-GatewaySubnet"].id
  }

  bgp_settings {
    asn = 65515
  }

  depends_on = [
    azurerm_subnet.subnet,
    azurerm_public_ip.vpngw_pip
  ]
}


# -------------------------------------------------------------------------
# 3. AZURE DNS PRIVATE RESOLVER (Flujo F4 - Resolución Interna/Externa)
# -------------------------------------------------------------------------
resource "azurerm_private_dns_resolver" "dns_resolver" {
  name                = "dns-hub-prod-swe-001"
  resource_group_name = azurerm_resource_group.net_rg["hub_prod"].name
  location            = var.location
  virtual_network_id  = azurerm_virtual_network.vnet["hub_prod"].id
  tags                = var.tags
  depends_on          = [azurerm_virtual_network.vnet]
}

resource "azurerm_private_dns_resolver_inbound_endpoint" "dns_inbound" {
  name                    = "din-hub-prod-swe-001"
  private_dns_resolver_id = azurerm_private_dns_resolver.dns_resolver.id
  location                = var.location
  tags                    = var.tags
  
  ip_configurations {
    private_ip_allocation_method = "Dynamic"
    subnet_id                    = azurerm_subnet.subnet["hub_prod-snet-hub-DNSin-prod-swe"].id
  }
}

resource "azurerm_private_dns_resolver_outbound_endpoint" "dns_outbound" {
  name                    = "dou-hub-prod-swe-001"
  private_dns_resolver_id = azurerm_private_dns_resolver.dns_resolver.id
  location                = var.location
  subnet_id               = azurerm_subnet.subnet["hub_prod-snet-hub-DNSout-prod-swe"].id
  tags                    = var.tags
}