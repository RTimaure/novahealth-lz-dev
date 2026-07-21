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
  # MAPA IPAM (SWE CENTRAL EXCLUSIVO - PROD, NON-PROD, ON-PREM)
  # CORRECCIÓN: Nombres de subred restaurados al primer despliegue (sin -001)
  # =========================================================================
  vnets = {
    # --------------------------------------------------------
    # 1. PRODUCCIÓN (Sweden Central)
    # --------------------------------------------------------
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

    # --------------------------------------------------------
    # 2. NON-PRODUCTION (Sweden Central)
    # --------------------------------------------------------
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

    # --------------------------------------------------------
    # 3. ON-PREMISE EMULADO (Sweden Central)
    # --------------------------------------------------------
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

  # =========================================================================
  # FLATTEN PARA BUCLE DE SUBREDES
  # =========================================================================
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

  # =========================================================================
  # TABLAS DE RUTEO (UDR) - ESTAS SÍ DEBEN TENER 5 SEGMENTOS (001)
  # =========================================================================
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
  # ASOCIACIONES: Conecta las subredes originales con las UDRs corregidas
  # =========================================================================
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

  # =========================================================================
  # VNET PEERINGS
  # =========================================================================
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

# -------------------------------------------------------------------------
# DESPLIEGUE - SE INCLUYEN TAGS DE POLÍTICA Y DEPENDENCIAS
# -------------------------------------------------------------------------

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

  depends_on = [azurerm_resource_group.net_rg]
}

resource "azurerm_subnet" "subnet" {
  for_each             = local.subnet_map
  name                 = each.value.subnet_name
  resource_group_name  = azurerm_resource_group.net_rg[each.value.vnet_key].name
  virtual_network_name = azurerm_virtual_network.vnet[each.value.vnet_key].name
  address_prefixes     = [each.value.subnet_cidr]

  depends_on = [azurerm_virtual_network.vnet]
}

resource "azurerm_route_table" "udr" {
  for_each                      = local.route_tables
  name                          = each.key
  location                      = var.location
  resource_group_name           = azurerm_resource_group.net_rg[each.value.rg_key].name
  disable_bgp_route_propagation = false
  tags                          = var.tags

  depends_on = [azurerm_resource_group.net_rg]
}

resource "azurerm_route" "routes" {
  for_each               = local.routes_map
  name                   = each.value.name
  resource_group_name    = azurerm_route_table.udr[each.value.rt].resource_group_name
  route_table_name       = azurerm_route_table.udr[each.value.rt].name
  address_prefix         = each.value.prefix
  next_hop_type          = each.value.next_hop
  next_hop_in_ip_address = each.value.next_hop == "VirtualAppliance" ? local.fw_private_ip : null

  depends_on = [azurerm_route_table.udr]
}

resource "azurerm_subnet_route_table_association" "udr_assoc" {
  for_each       = local.subnet_udr_associations
  subnet_id      = azurerm_subnet.subnet[each.key].id
  route_table_id = azurerm_route_table.udr[each.value].id

  depends_on = [
    azurerm_subnet.subnet,
    azurerm_route_table.udr,
    azurerm_route.routes
  ]
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

  depends_on = [azurerm_virtual_network.vnet]
}