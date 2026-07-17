# Archivo: modules/networking/main.tf

terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
  }
}

locals {
  # =========================================================================
  # BASE DE DATOS DE TOPOLOGÍA (IPAM CSV - NOVAHEALTH)
  # Cumplimiento estricto de Naming Policy: <tipo>-<app>-<env>-<region>-<num>
  # =========================================================================
  vnets = {
    # --------------------------------------------------------
    # ENTORNO: PRODUCCIÓN (Sweden Central)
    # --------------------------------------------------------
    hub_prod = {
      name          = "vnet-hub-prod-swe-001"
      rg_name       = "rg-hub-prod-swe-001"
      location      = var.location
      address_space = ["10.0.0.0/22"]
      is_hub        = true
      hub_key       = null
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
      is_hub        = false
      hub_key       = "hub_prod"
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
      is_hub        = false
      hub_key       = "hub_prod"
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
      is_hub        = false
      hub_key       = "hub_prod"
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
      is_hub        = false
      hub_key       = "hub_prod"
      subnets = {
        "snet-shared-pe-prod-swe"          = "10.0.11.0/25"
        "snet-shared-APImngt-prod-swe"     = "10.0.11.128/26"
        "snet-shared-devopstools-prod-swe" = "10.0.11.192/27"
      }
    }

    # --------------------------------------------------------
    # ENTORNO: NON-PRODUCTION (Sweden Central)
    # --------------------------------------------------------
    hub_nprod = {
      name          = "vnet-hub-nprod-swe-001"
      rg_name       = "rg-hub-nprod-swe-001"
      location      = var.location
      address_space = ["10.1.0.0/22"]
      is_hub        = true
      hub_key       = null
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
      is_hub        = false
      hub_key       = "hub_nprod"
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
      is_hub        = false
      hub_key       = "hub_nprod"
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
      is_hub        = false
      hub_key       = "hub_nprod"
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
      is_hub        = false
      hub_key       = "hub_nprod"
      subnets = {
        "snet-shared-pe-nprod-swe"          = "10.1.11.0/25"
        "snet-shared-APImngt-nprod-swe"     = "10.1.11.128/26"
        "snet-shared-devopstools-nprod-swe" = "10.1.11.192/27"
      }
    }

    # --------------------------------------------------------
    # ENTORNO: DISASTER RECOVERY (West Europe)
    # --------------------------------------------------------
    hub_dr = {
      name          = "vnet-hub-dr-weu-001"
      rg_name       = "rg-hub-dr-weu-001"
      location      = "westeurope"
      address_space = ["10.4.0.0/22"]
      is_hub        = true
      hub_key       = null
      subnets = {
        "snet-hub-mngt-dr-weu"   = "10.4.0.0/24"
        "snet-hub-pe-dr-weu"     = "10.4.1.0/24"
        "AzureFirewallSubnet"    = "10.4.2.0/26"
        "snet-hub-appgw-dr-weu"  = "10.4.2.64/26"
        "GatewaySubnet"          = "10.4.2.128/26"
        "AzureBastionSubnet"     = "10.4.2.192/26"
        "snet-hub-DNSin-dr-weu"  = "10.4.3.0/27"
        "snet-hub-DNSout-dr-weu" = "10.4.3.32/27"
      }
    }
    aks_dr = {
      name          = "vnet-aks-dr-weu-001"
      rg_name       = "rg-aks-dr-weu-001"
      location      = "westeurope"
      address_space = ["10.4.4.0/22"]
      is_hub        = false
      hub_key       = "hub_dr"
      subnets = {
        "snet-aks-workload-dr-weu"   = "10.4.4.0/23"
        "snet-aks-system-dr-weu"     = "10.4.6.0/24"
        "snet-aks-ingress-dr-weu"    = "10.4.7.0/26"
        "snet-aks-monitoring-dr-weu" = "10.4.7.64/27"
        "snet-aks-pe-dr-weu"         = "10.4.7.96/27"
      }
    }
    dataia_dr = {
      name          = "vnet-dataia-dr-weu-001"
      rg_name       = "rg-dataia-dr-weu-001"
      location      = "westeurope"
      address_space = ["10.4.8.0/23"]
      is_hub        = false
      hub_key       = "hub_dr"
      subnets = {
        "snet-dataia-pe-dr-weu"          = "10.4.8.0/25"
        "snet-dataia-analytics-dr-weu"   = "10.4.8.128/25"
        "snet-dataia-datacompute-dr-weu" = "10.4.9.0/25"
        "snet-dataia-streamming-dr-weu"  = "10.4.9.128/26"
      }
    }
    apps_dr = {
      name          = "vnet-apps-dr-weu-001"
      rg_name       = "rg-apps-dr-weu-001"
      location      = "westeurope"
      address_space = ["10.4.10.0/24"]
      is_hub        = false
      hub_key       = "hub_dr"
      subnets = {
        "snet-apps-aca-dr-weu"       = "10.4.10.0/25"
        "snet-apps-messaging-dr-weu" = "10.4.10.128/26"
        "snet-apps-pe-dr-weu"        = "10.4.10.192/26"
      }
    }
    shared_dr = {
      name          = "vnet-shared-dr-weu-001"
      rg_name       = "rg-shared-dr-weu-001"
      location      = "westeurope"
      address_space = ["10.4.11.0/24"]
      is_hub        = false
      hub_key       = "hub_dr"
      subnets = {
        "snet-shared-pe-dr-weu"          = "10.4.11.0/25"
        "snet-shared-APImngt-dr-weu"     = "10.4.11.128/26"
        "snet-shared-devopstools-dr-weu" = "10.4.11.192/27"
      }
    }

    # --------------------------------------------------------
    # ENTORNO: ON-PREMISE EMULADO (Sweden Central)
    # --------------------------------------------------------
    onprem_prod = {
      name          = "vnet-onprem-prod-swe-001"
      rg_name       = "rg-onprem-prod-swe-001"
      location      = var.location
      address_space = ["172.16.0.0/16"]
      is_hub        = true # Aisla la red para que no haga peering nativo como Spoke
      hub_key       = null
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
  # LÓGICA DE PROCESAMIENTO DINÁMICO (FLATTEN)
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

  spoke_peerings = {
    for k, v in local.vnets : k => v if !v.is_hub && v.hub_key != null
  }
}

# -------------------------------------------------------------------------
# 2. RESOURCE GROUPS (REDES) - CUMPLIMIENTO DE ETIQUETADO
# -------------------------------------------------------------------------
resource "azurerm_resource_group" "net_rg" {
  for_each = local.vnets
  name     = each.value.rg_name
  location = each.value.location
  tags     = var.tags
}

# -------------------------------------------------------------------------
# 3. VIRTUAL NETWORKS - CUMPLIMIENTO DE ETIQUETADO
# -------------------------------------------------------------------------
resource "azurerm_virtual_network" "vnet" {
  for_each            = local.vnets
  name                = each.value.name
  location            = azurerm_resource_group.net_rg[each.key].location
  resource_group_name = azurerm_resource_group.net_rg[each.key].name
  address_space       = each.value.address_space
  tags                = var.tags
}

# -------------------------------------------------------------------------
# 4. SUBNETS
# -------------------------------------------------------------------------
resource "azurerm_subnet" "subnet" {
  for_each             = local.subnet_map
  name                 = each.value.subnet_name
  resource_group_name  = azurerm_resource_group.net_rg[each.value.vnet_key].name
  virtual_network_name = azurerm_virtual_network.vnet[each.value.vnet_key].name
  address_prefixes     = [each.value.subnet_cidr]
}

# -------------------------------------------------------------------------
# 5. VNET PEERINGS (SPOKE TO HUB / HUB TO SPOKE)
# -------------------------------------------------------------------------
resource "azurerm_virtual_network_peering" "hub_to_spoke" {
  for_each                     = local.spoke_peerings
  name                         = "peer-hub-to-${each.key}"
  resource_group_name          = azurerm_resource_group.net_rg[each.value.hub_key].name
  virtual_network_name         = azurerm_virtual_network.vnet[each.value.hub_key].name
  remote_virtual_network_id    = azurerm_virtual_network.vnet[each.key].id
  allow_virtual_network_access = true
  allow_forwarded_traffic      = true

  # 🚀 Espera a que terminen TODAS las VNets y Subredes de crearse
  depends_on = [
    azurerm_virtual_network.vnet,
    azurerm_subnet.subnet
  ]
}

resource "azurerm_virtual_network_peering" "spoke_to_hub" {
  for_each                     = local.spoke_peerings
  name                         = "peer-${each.key}-to-hub"
  resource_group_name          = azurerm_resource_group.net_rg[each.key].name
  virtual_network_name         = azurerm_virtual_network.vnet[each.key].name
  remote_virtual_network_id    = azurerm_virtual_network.vnet[each.value.hub_key].id
  allow_virtual_network_access = true
  allow_forwarded_traffic      = true

  # 🚀 Espera a que terminen TODAS las VNets y Subredes de crearse
  depends_on = [
    azurerm_virtual_network.vnet,
    azurerm_subnet.subnet
  ]
}

# -------------------------------------------------------------------------
# 6. GLOBAL VNET PEERING (HUB PROD <--> HUB DR)
# -------------------------------------------------------------------------
resource "azurerm_virtual_network_peering" "hub_prod_to_dr" {
  name                         = "peer-hub_prod-to-hub_dr"
  resource_group_name          = azurerm_resource_group.net_rg["hub_prod"].name
  virtual_network_name         = azurerm_virtual_network.vnet["hub_prod"].name
  remote_virtual_network_id    = azurerm_virtual_network.vnet["hub_dr"].id
  allow_virtual_network_access = true
  allow_forwarded_traffic      = true

  # 🚀 Espera a que terminen TODAS las VNets y Subredes de crearse
  depends_on = [
    azurerm_virtual_network.vnet,
    azurerm_subnet.subnet
  ]
}

resource "azurerm_virtual_network_peering" "hub_dr_to_prod" {
  name                         = "peer-hub_dr-to-hub_prod"
  resource_group_name          = azurerm_resource_group.net_rg["hub_dr"].name
  virtual_network_name         = azurerm_virtual_network.vnet["hub_dr"].name
  remote_virtual_network_id    = azurerm_virtual_network.vnet["hub_prod"].id
  allow_virtual_network_access = true
  allow_forwarded_traffic      = true

  # 🚀 Espera a que terminen TODAS las VNets y Subredes de crearse
  depends_on = [
    azurerm_virtual_network.vnet,
    azurerm_subnet.subnet
  ]
}