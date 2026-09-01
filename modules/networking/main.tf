# Archivo: modules/networking/main.tf

locals {
  fw_private_ip = "10.0.2.4"

  # Helper para obtener tags dinámicamente según el Resource Group asignado
  get_tags = {
    for k, v in var.resource_group_names : k => lookup(var.resource_group_tags, k, var.tags)
  }

  vnets = {
    hub_prod = {
      name          = "vnet-hub-prod-swe"
      rg_name       = lookup(var.resource_group_names, "rg-nethub-prod-swe", "rg-nethub-prod-swe")
      address_space = ["10.0.0.0/22"]
      subnets = {
        "snet-hub-mngt-prod-swe"   = "10.0.0.0/24"
        "snet-hub-pe-prod-swe"     = "10.0.1.0/24"
        "AzureFirewallSubnet"      = "10.0.2.0/26"
        "snet-hub-appgw-prod-swe"  = "10.0.2.64/26"
        "GatewaySubnet"            = "10.0.2.128/26"
        "AzureBastionSubnet"       = "10.0.2.192/26"
        "snet-hub-dnsin-prod-swe"  = "10.0.3.0/27"
        "snet-hub-dnsout-prod-swe" = "10.0.3.32/27"
      }
    }
    aks_prod = {
      name          = "vnet-aks-prod-swe"
      rg_name       = lookup(var.resource_group_names, "rg-netaks-prod-swe", "rg-netaks-prod-swe")
      address_space = ["10.0.4.0/22"]
      subnets = {
        "snet-aks-workload-prod-swe"   = "10.0.4.0/23"
        "snet-aks-system-prod-swe"     = "10.0.6.0/24"
        "snet-aks-ingress-prod-swe"    = "10.0.7.0/26"
        "snet-aks-pe-prod-swe"         = "10.0.7.64/26"
        "snet-aks-monitoring-prod-swe" = "10.0.7.128/27"
      }
    }
    dataai_prod = {
      name          = "vnet-dataai-prod-swe"
      rg_name       = lookup(var.resource_group_names, "rg-netdataai-prod-swe", "rg-netdataai-prod-swe")
      address_space = ["10.0.8.0/23"]
      subnets = {
        "snet-dataai-pe-prod-swe"        = "10.0.8.0/25"
        "snet-dataai-analytics-prod-swe" = "10.0.8.128/25"
        "snet-dataai-compute-prod-swe"   = "10.0.9.0/25"
        "snet-dataai-streaming-prod-swe" = "10.0.9.128/26"
      }
    }
    apps_prod = {
      name          = "vnet-apps-prod-swe"
      rg_name       = lookup(var.resource_group_names, "rg-netapps-prod-swe", "rg-netapps-prod-swe")
      address_space = ["10.0.10.0/24"]
      subnets = {
        "snet-apps-aca-prod-swe"       = "10.0.10.0/25"
        "snet-apps-messaging-prod-swe" = "10.0.10.128/26"
        "snet-apps-pe-prod-swe"        = "10.0.10.192/26"
      }
    }
    shared_prod = {
      name          = "vnet-shared-prod-swe"
      rg_name       = lookup(var.resource_group_names, "rg-netshared-prod-swe", "rg-netshared-prod-swe")
      address_space = ["10.0.11.0/24"]
      subnets = {
        "snet-shared-pe-prod-swe"     = "10.0.11.0/25"
        "snet-shared-apim-prod-swe"   = "10.0.11.128/26"
        "snet-shared-devops-prod-swe" = "10.0.11.192/27"
      }
    }
    /*hub_nprod = {
      name          = "vnet-hub-nprod-swe"
      rg_name       = lookup(var.resource_group_names, "rg-netdev-dev-swe", "rg-netdev-dev-swe")
      address_space = ["10.1.0.0/22"]
      subnets = {
        "snet-hub-mngt-nprod-swe"   = "10.1.0.0/24"
        "snet-hub-pe-nprod-swe"     = "10.1.1.0/24"
        "AzureFirewallSubnet"       = "10.1.2.0/26"
        "snet-hub-appgw-nprod-swe"  = "10.1.2.64/26"
        "GatewaySubnet"             = "10.1.2.128/26"
        "AzureBastionSubnet"        = "10.1.2.192/26"
        "snet-hub-dnsin-nprod-swe"  = "10.1.3.0/27"
        "snet-hub-dnsout-nprod-swe" = "10.1.3.32/27"
      }
    }
    aks_nprod = {
      name          = "vnet-aks-nprod-swe"
      rg_name       = lookup(var.resource_group_names, "rg-netdev-dev-swe", "rg-netdev-dev-swe")
      address_space = ["10.1.4.0/22"]
      subnets = {
        "snet-aks-workload-nprod-swe"   = "10.1.4.0/23"
        "snet-aks-system-nprod-swe"     = "10.1.6.0/24"
        "snet-aks-ingress-nprod-swe"    = "10.1.7.0/26"
        "snet-aks-monitoring-nprod-swe" = "10.1.7.64/27"
        "snet-aks-pe-nprod-swe"         = "10.1.7.96/27"
      }
    }
    dataai_nprod = {
      name          = "vnet-dataai-nprod-swe"
      rg_name       = lookup(var.resource_group_names, "rg-netdev-dev-swe", "rg-netdev-dev-swe")
      address_space = ["10.1.8.0/23"]
      subnets = {
        "snet-dataai-pe-nprod-swe"        = "10.1.8.0/25"
        "snet-dataai-analytics-nprod-swe" = "10.1.8.128/25"
        "snet-dataai-compute-nprod-swe"   = "10.1.9.0/25"
        "snet-dataai-streaming-nprod-swe" = "10.1.9.128/26"
      }
    }
    apps_nprod = {
      name          = "vnet-apps-nprod-swe"
      rg_name       = lookup(var.resource_group_names, "rg-netdev-dev-swe", "rg-netdev-dev-swe")
      address_space = ["10.1.10.0/24"]
      subnets = {
        "snet-apps-aca-nprod-swe"       = "10.1.10.0/25"
        "snet-apps-messaging-nprod-swe" = "10.1.10.128/26"
        "snet-apps-pe-nprod-swe"        = "10.1.10.192/26"
      }
    }
    shared_nprod = {
      name          = "vnet-shared-nprod-swe"
      rg_name       = lookup(var.resource_group_names, "rg-netdev-dev-swe", "rg-netdev-dev-swe")
      address_space = ["10.1.11.0/24"]
      subnets = {
        "snet-shared-pe-nprod-swe"     = "10.1.11.0/25"
        "snet-shared-apim-nprod-swe"   = "10.1.11.128/26"
        "snet-shared-devops-nprod-swe"  = "10.1.11.192/27"
      }
    }*/
    onprem_prod = {
      name          = "vnet-onprem-prod-swe"
      rg_name       = lookup(var.resource_group_names, "rg-nethub-prod-swe", "rg-nethub-prod-swe")
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
        rg_name     = vnet.rg_name
        subnet_name = skey
        subnet_cidr = scidr
      }
    ]
  ])

  subnet_map = {
    for s in local.subnet_list : "${s.vnet_key}_${s.subnet_name}" => s
  }

  # --- HUB: split por suscripción real ---
  hub_vnets_prod    = { for k, v in local.vnets : k => v if k == "hub_prod" || k == "onprem_prod" }
  #hub_vnets_nprod   = { for k, v in local.vnets : k => v if k == "hub_nprod" }
  hub_subnets_prod  = { for k, v in local.subnet_map : k => v if v.vnet_key == "hub_prod" || v.vnet_key == "onprem_prod" }
  #hub_subnets_nprod = { for k, v in local.subnet_map : k => v if v.vnet_key == "hub_nprod" }

  # --- DATA & IA: split por suscripción real ---
  data_vnets_prod    = { for k, v in local.vnets : k => v if k == "dataai_prod" }
  #data_vnets_nprod   = { for k, v in local.vnets : k => v if k == "dataai_nprod" }
  data_subnets_prod  = { for k, v in local.subnet_map : k => v if v.vnet_key == "dataai_prod" }
  #data_subnets_nprod = { for k, v in local.subnet_map : k => v if v.vnet_key == "dataai_nprod" }

  # --- PROD (aks/apps): usa provider=production ---
  prod_vnets   = { for k, v in local.vnets : k => v if length(regexall("^(aks|apps)", k)) > 0 || k == "shared_nprod" }
  prod_subnets = { for k, v in local.subnet_map : k => v if length(regexall("^(aks|apps)", v.vnet_key)) > 0 || v.vnet_key == "shared_nprod" }

  # --- SHARED SERVICES PROD: asignado a Platform Services (data_ai) ---
  shared_vnets_prod   = { for k, v in local.vnets : k => v if k == "shared_prod" }
  shared_subnets_prod = { for k, v in local.subnet_map : k => v if v.vnet_key == "shared_prod" }

  # Para los peerings hub->prod
  prod_vnets_envprod  = { for k, v in local.prod_vnets : k => v if length(regexall("nprod", k)) == 0 }
  #prod_vnets_envnprod = { for k, v in local.prod_vnets : k => v if length(regexall("nprod", k)) > 0 }
}

# =========================================================================
# DOMINIO HUB Y ON-PREMISE — PROD (SUSCRIPCIÓN: CONNECTIVITY)
# =========================================================================
resource "azurerm_virtual_network" "hub_prod" {
  provider            = azurerm.connectivity
  for_each            = local.hub_vnets_prod
  name                = each.value.name
  location            = var.location
  resource_group_name = each.value.rg_name
  address_space       = each.value.address_space
  tags                = lookup(var.resource_group_tags, each.value.rg_name, var.tags)
}

resource "azurerm_subnet" "hub_prod" {
  provider             = azurerm.connectivity
  for_each             = local.hub_subnets_prod
  name                 = each.value.subnet_name
  resource_group_name  = each.value.rg_name
  virtual_network_name = azurerm_virtual_network.hub_prod[each.value.vnet_key].name
  address_prefixes     = [each.value.subnet_cidr]

  dynamic "delegation" {
    for_each = length(regexall("dnsin|dnsout", lower(each.value.subnet_name))) > 0 ? [1] : []
    content {
      name = "Microsoft.Network.dnsResolvers"
      service_delegation {
        name    = "Microsoft.Network/dnsResolvers"
        actions = ["Microsoft.Network/virtualNetworks/subnets/join/action"]
      }
    }
  }
}

resource "azurerm_network_security_group" "hub_nsgs_prod" {
  provider            = azurerm.connectivity
  for_each            = { for k, v in local.hub_subnets_prod : k => v if !contains(["AzureFirewallSubnet", "GatewaySubnet"], v.subnet_name) }
  name                = each.value.subnet_name == "AzureBastionSubnet" ? "nsg-hub-bastion-prod-swe" : replace(each.value.subnet_name, "snet-", "nsg-")
  location            = var.location
  resource_group_name = each.value.rg_name
  tags                = lookup(var.resource_group_tags, each.value.rg_name, var.tags)
}

resource "azurerm_subnet_network_security_group_association" "hub_prod" {
  provider                  = azurerm.connectivity
  for_each                  = { for k, v in local.hub_subnets_prod : k => v if !contains(["AzureFirewallSubnet", "GatewaySubnet"], v.subnet_name) }
  subnet_id                 = azurerm_subnet.hub_prod[each.key].id
  network_security_group_id = azurerm_network_security_group.hub_nsgs_prod[each.key].id

  depends_on = [
    azurerm_network_security_rule.hub_rules_prod
  ]
}

# =========================================================================
# DOMINIO HUB — NPROD/DEV (SUSCRIPCIÓN: PRODUCTION)
# =========================================================================
/*resource "azurerm_virtual_network" "hub_nprod" {
  provider            = azurerm.production
  for_each            = local.hub_vnets_nprod
  name                = each.value.name
  location            = var.location
  resource_group_name = each.value.rg_name
  address_space       = each.value.address_space
  tags                = lookup(var.resource_group_tags, each.value.rg_name, var.tags)
}

resource "azurerm_subnet" "hub_nprod" {
  provider             = azurerm.production
  for_each             = local.hub_subnets_nprod
  name                 = each.value.subnet_name
  resource_group_name  = each.value.rg_name
  virtual_network_name = azurerm_virtual_network.hub_nprod[each.value.vnet_key].name
  address_prefixes     = [each.value.subnet_cidr]

  dynamic "delegation" {
    for_each = length(regexall("dnsin|dnsout", lower(each.value.subnet_name))) > 0 ? [1] : []
    content {
      name = "Microsoft.Network.dnsResolvers"
      service_delegation {
        name    = "Microsoft.Network/dnsResolvers"
        actions = ["Microsoft.Network/virtualNetworks/subnets/join/action"]
      }
    }
  }
}

resource "azurerm_network_security_group" "hub_nsgs_nprod" {
  provider            = azurerm.production
  for_each            = { for k, v in local.hub_subnets_nprod : k => v if !contains(["AzureFirewallSubnet", "GatewaySubnet"], v.subnet_name) }
  name                = each.value.subnet_name == "AzureBastionSubnet" ? "nsg-hub-bastion-nprod-swe" : replace(each.value.subnet_name, "snet-", "nsg-")
  location            = var.location
  resource_group_name = each.value.rg_name
  tags                = lookup(var.resource_group_tags, each.value.rg_name, var.tags)
}

resource "azurerm_subnet_network_security_group_association" "hub_nprod" {
  provider                  = azurerm.production
  for_each                  = { for k, v in local.hub_subnets_nprod : k => v if !contains(["AzureFirewallSubnet", "GatewaySubnet"], v.subnet_name) }
  subnet_id                 = azurerm_subnet.hub_nprod[each.key].id
  network_security_group_id = azurerm_network_security_group.hub_nsgs_nprod[each.key].id

  depends_on = [
    azurerm_network_security_rule.hub_rules_nprod
  ]
}
*/
# =========================================================================
# DOMINIO DATA & IA — PROD (SUSCRIPCIÓN: DATA AND IA PLATFORM)
# =========================================================================
resource "azurerm_virtual_network" "data_prod" {
  provider            = azurerm.data_ai
  for_each            = local.data_vnets_prod
  name                = each.value.name
  location            = var.location
  resource_group_name = each.value.rg_name
  address_space       = each.value.address_space
  tags                = lookup(var.resource_group_tags, each.value.rg_name, var.tags)
}

resource "azurerm_subnet" "data_prod" {
  provider             = azurerm.data_ai
  for_each             = local.data_subnets_prod
  name                 = each.value.subnet_name
  resource_group_name  = each.value.rg_name
  virtual_network_name = azurerm_virtual_network.data_prod[each.value.vnet_key].name
  address_prefixes     = [each.value.subnet_cidr]
}

resource "azurerm_network_security_group" "data_nsgs_prod" {
  provider            = azurerm.data_ai
  for_each            = local.data_subnets_prod
  name                = replace(each.value.subnet_name, "snet-", "nsg-")
  location            = var.location
  resource_group_name = each.value.rg_name
  tags                = lookup(var.resource_group_tags, each.value.rg_name, var.tags)
}

resource "azurerm_subnet_network_security_group_association" "data_prod" {
  provider                  = azurerm.data_ai
  for_each                  = local.data_subnets_prod
  subnet_id                 = azurerm_subnet.data_prod[each.key].id
  network_security_group_id = azurerm_network_security_group.data_nsgs_prod[each.key].id

  depends_on = [
    azurerm_network_security_rule.data_ai_rules_prod
  ]
}

# =========================================================================
# DOMINIO DATA & IA — NPROD/DEV (SUSCRIPCIÓN: PRODUCTION)
# =========================================================================
/*resource "azurerm_virtual_network" "data_nprod" {
  provider            = azurerm.production
  for_each            = local.data_vnets_nprod
  name                = each.value.name
  location            = var.location
  resource_group_name = each.value.rg_name
  address_space       = each.value.address_space
  tags                = lookup(var.resource_group_tags, each.value.rg_name, var.tags)
}

resource "azurerm_subnet" "data_nprod" {
  provider             = azurerm.production
  for_each             = local.data_subnets_nprod
  name                 = each.value.subnet_name
  resource_group_name  = each.value.rg_name
  virtual_network_name = azurerm_virtual_network.data_nprod[each.value.vnet_key].name
  address_prefixes     = [each.value.subnet_cidr]
}

resource "azurerm_network_security_group" "data_nsgs_nprod" {
  provider            = azurerm.production
  for_each            = local.data_subnets_nprod
  name                = replace(each.value.subnet_name, "snet-", "nsg-")
  location            = var.location
  resource_group_name = each.value.rg_name
  tags                = lookup(var.resource_group_tags, each.value.rg_name, var.tags)
}

resource "azurerm_subnet_network_security_group_association" "data_nprod" {
  provider                  = azurerm.production
  for_each                  = local.data_subnets_nprod
  subnet_id                 = azurerm_subnet.data_nprod[each.key].id
  network_security_group_id = azurerm_network_security_group.data_nsgs_nprod[each.key].id

  depends_on = [
    azurerm_network_security_rule.data_ai_rules_nprod
  ]
}
*/
# =========================================================================
# DOMINIO SHARED SERVICES — PROD (SUSCRIPCIÓN: PLATFORM SERVICES / DATA_AI)
# =========================================================================
resource "azurerm_virtual_network" "shared_prod" {
  provider            = azurerm.data_ai
  for_each            = local.shared_vnets_prod
  name                = each.value.name
  location            = var.location
  resource_group_name = each.value.rg_name
  address_space       = each.value.address_space
  tags                = lookup(var.resource_group_tags, each.value.rg_name, var.tags)
}

resource "azurerm_subnet" "shared_prod" {
  provider             = azurerm.data_ai
  for_each             = local.shared_subnets_prod
  name                 = each.value.subnet_name
  resource_group_name  = each.value.rg_name
  virtual_network_name = azurerm_virtual_network.shared_prod[each.value.vnet_key].name
  address_prefixes     = [each.value.subnet_cidr]
}

resource "azurerm_network_security_group" "shared_nsgs_prod" {
  provider            = azurerm.data_ai
  for_each            = local.shared_subnets_prod
  name                = replace(each.value.subnet_name, "snet-", "nsg-")
  location            = var.location
  resource_group_name = each.value.rg_name
  tags                = lookup(var.resource_group_tags, each.value.rg_name, var.tags)
}

resource "azurerm_subnet_network_security_group_association" "shared_prod" {
  provider                  = azurerm.data_ai
  for_each                  = local.shared_subnets_prod
  subnet_id                 = azurerm_subnet.shared_prod[each.key].id
  network_security_group_id = azurerm_network_security_group.shared_nsgs_prod[each.key].id

  depends_on = [
    azurerm_network_security_rule.prod_rules
  ]
}

# =========================================================================
# DOMINIO PRODUCCIÓN (aks/apps/shared_nprod) — SUSCRIPCIÓN PRODUCTION
# =========================================================================
resource "azurerm_virtual_network" "prod" {
  provider            = azurerm.production
  for_each            = local.prod_vnets
  name                = each.value.name
  location            = var.location
  resource_group_name = each.value.rg_name
  address_space       = each.value.address_space
  tags                = lookup(var.resource_group_tags, each.value.rg_name, var.tags)
}

resource "azurerm_subnet" "prod" {
  provider             = azurerm.production
  for_each             = local.prod_subnets
  name                 = each.value.subnet_name
  resource_group_name  = each.value.rg_name
  virtual_network_name = azurerm_virtual_network.prod[each.value.vnet_key].name
  address_prefixes     = [each.value.subnet_cidr]
}

resource "azurerm_network_security_group" "prod_nsgs" {
  provider            = azurerm.production
  for_each            = local.prod_subnets
  name                = replace(each.value.subnet_name, "snet-", "nsg-")
  location            = var.location
  resource_group_name = each.value.rg_name
  tags                = lookup(var.resource_group_tags, each.value.rg_name, var.tags)
}

resource "azurerm_subnet_network_security_group_association" "prod" {
  provider                  = azurerm.production
  for_each                  = local.prod_subnets
  subnet_id                 = azurerm_subnet.prod[each.key].id
  network_security_group_id = azurerm_network_security_group.prod_nsgs[each.key].id

  depends_on = [
    azurerm_network_security_rule.prod_rules
  ]
}

# =========================================================================
# GLOBAL VNET PEERINGS (CLÚSTER C2)
# =========================================================================
resource "azurerm_virtual_network_peering" "hub_to_prod_prod" {
  provider                     = azurerm.connectivity
  for_each                     = local.prod_vnets_envprod
  name                         = "peer-hub-${replace(each.key, "_prod", "")}-prod-swe"
  resource_group_name          = local.vnets["hub_prod"].rg_name
  virtual_network_name         = azurerm_virtual_network.hub_prod["hub_prod"].name
  remote_virtual_network_id    = azurerm_virtual_network.prod[each.key].id
  allow_virtual_network_access = true
  allow_forwarded_traffic      = true
  allow_gateway_transit        = true
  use_remote_gateways          = false
  depends_on                   = [azurerm_subnet.hub_prod, azurerm_subnet.prod, azurerm_virtual_network_gateway.vpngw]
}

/*
resource "azurerm_virtual_network_peering" "hub_to_prod_nprod" {
  provider                     = azurerm.production
  for_each                     = local.prod_vnets_envnprod
  name                         = "peer-hub-${replace(each.key, "_nprod", "")}-dev-swe"
  resource_group_name          = local.vnets["hub_nprod"].rg_name
  virtual_network_name         = azurerm_virtual_network.hub_nprod["hub_nprod"].name
  remote_virtual_network_id    = azurerm_virtual_network.prod[each.key].id
  allow_virtual_network_access = true
  allow_forwarded_traffic      = true
  allow_gateway_transit        = true
  use_remote_gateways          = false
  depends_on                   = [azurerm_subnet.hub_nprod, azurerm_subnet.prod]
}
*/
/*resource "azurerm_virtual_network_peering" "prod_to_hub" {
  provider                     = azurerm.production
  for_each                     = local.prod_vnets
  name                         = length(regexall("nprod", each.key)) > 0 ? "peer-${replace(each.key, "_nprod", "")}-hub-dev-swe" : "peer-${replace(each.key, "_prod", "")}-hub-prod-swe"
  resource_group_name          = each.value.rg_name
  virtual_network_name         = azurerm_virtual_network.prod[each.key].name
  remote_virtual_network_id    = length(regexall("nprod", each.key)) > 0 ? azurerm_virtual_network.hub_nprod["hub_nprod"].id : azurerm_virtual_network.hub_prod["hub_prod"].id
  allow_virtual_network_access = true
  allow_forwarded_traffic      = true
  allow_gateway_transit        = false
  use_remote_gateways          = length(regexall("nprod", each.key)) > 0 ? false : true
  depends_on                   = [azurerm_subnet.prod, azurerm_subnet.hub_prod, azurerm_subnet.hub_nprod, azurerm_firewall.fw, azurerm_virtual_network_gateway.vpngw]
}
*/
resource "azurerm_virtual_network_peering" "hub_to_data_prod" {
  provider                     = azurerm.connectivity
  for_each                     = local.data_vnets_prod
  name                         = "peer-hub-dataai-prod-swe"
  resource_group_name          = local.vnets["hub_prod"].rg_name
  virtual_network_name         = azurerm_virtual_network.hub_prod["hub_prod"].name
  remote_virtual_network_id    = azurerm_virtual_network.data_prod[each.key].id
  allow_virtual_network_access = true
  allow_forwarded_traffic      = true
  allow_gateway_transit        = true
  use_remote_gateways          = false
  depends_on                   = [azurerm_subnet.hub_prod, azurerm_subnet.data_prod, azurerm_virtual_network_gateway.vpngw]
}
/*
resource "azurerm_virtual_network_peering" "hub_to_data_nprod" {
  provider                     = azurerm.production
  for_each                     = local.data_vnets_nprod
  name                         = "peer-hub-dataai-dev-swe"
  resource_group_name          = local.vnets["hub_nprod"].rg_name
  virtual_network_name         = azurerm_virtual_network.hub_nprod["hub_nprod"].name
  remote_virtual_network_id    = azurerm_virtual_network.data_nprod[each.key].id
  allow_virtual_network_access = true
  allow_forwarded_traffic      = true
  allow_gateway_transit        = true
  use_remote_gateways          = false
  depends_on                   = [azurerm_subnet.hub_nprod, azurerm_subnet.data_nprod]
}
*/
resource "azurerm_virtual_network_peering" "data_to_hub_prod" {
  provider                     = azurerm.data_ai
  for_each                     = local.data_vnets_prod
  name                         = "peer-dataai-hub-prod-swe"
  resource_group_name          = each.value.rg_name
  virtual_network_name         = azurerm_virtual_network.data_prod[each.key].name
  remote_virtual_network_id    = azurerm_virtual_network.hub_prod["hub_prod"].id
  allow_virtual_network_access = true
  allow_forwarded_traffic      = true
  allow_gateway_transit        = false
  use_remote_gateways          = true
  depends_on                   = [azurerm_subnet.data_prod, azurerm_subnet.hub_prod, azurerm_virtual_network_gateway.vpngw]
}

/*resource "azurerm_virtual_network_peering" "data_to_hub_nprod" {
  provider                     = azurerm.production
  for_each                     = local.data_vnets_nprod
  name                         = "peer-dataai-hub-dev-swe"
  resource_group_name          = each.value.rg_name
  virtual_network_name         = azurerm_virtual_network.data_nprod[each.key].name
  remote_virtual_network_id    = azurerm_virtual_network.hub_nprod["hub_nprod"].id
  allow_virtual_network_access = true
  allow_forwarded_traffic      = true
  allow_gateway_transit        = false
  use_remote_gateways          = false
  depends_on                   = [azurerm_subnet.data_nprod, azurerm_subnet.hub_nprod]
}
*/
resource "azurerm_virtual_network_peering" "hub_to_shared_prod" {
  provider                     = azurerm.connectivity
  for_each                     = local.shared_vnets_prod
  name                         = "peer-hub-shared-prod-swe"
  resource_group_name          = local.vnets["hub_prod"].rg_name
  virtual_network_name         = azurerm_virtual_network.hub_prod["hub_prod"].name
  remote_virtual_network_id    = azurerm_virtual_network.shared_prod[each.key].id
  allow_virtual_network_access = true
  allow_forwarded_traffic      = true
  allow_gateway_transit        = true
  use_remote_gateways          = false
  depends_on                   = [azurerm_subnet.hub_prod, azurerm_subnet.shared_prod, azurerm_virtual_network_gateway.vpngw]
}

resource "azurerm_virtual_network_peering" "shared_to_hub_prod" {
  provider                     = azurerm.data_ai
  for_each                     = local.shared_vnets_prod
  name                         = "peer-shared-hub-prod-swe"
  resource_group_name          = each.value.rg_name
  virtual_network_name         = azurerm_virtual_network.shared_prod[each.key].name
  remote_virtual_network_id    = azurerm_virtual_network.hub_prod["hub_prod"].id
  allow_virtual_network_access = true
  allow_forwarded_traffic      = true
  allow_gateway_transit        = false
  use_remote_gateways          = true
  depends_on                   = [azurerm_subnet.shared_prod, azurerm_subnet.hub_prod, azurerm_virtual_network_gateway.vpngw]
}

# -------------------------------------------------------------------------
# 1. PEERING: AKS SPOKE -> HUB PROD
# -------------------------------------------------------------------------
resource "azurerm_virtual_network_peering" "aks_to_hub_prod" {
  provider                     = azurerm.production
  name                         = "peer-aks-hub-prod-swe"
  resource_group_name          = lookup(var.resource_group_names, "rg-netaks-prod-swe", "rg-netaks-prod-swe")
  virtual_network_name         = azurerm_virtual_network.prod["aks_prod"].name
  remote_virtual_network_id    = azurerm_virtual_network.hub_prod["hub_prod"].id

  allow_virtual_network_access = true
  allow_forwarded_traffic      = true
  allow_gateway_transit        = false
  use_remote_gateways          = true

  depends_on = [
    azurerm_subnet.prod,
    azurerm_subnet.hub_prod,
    azurerm_virtual_network_gateway.vpngw
  ]
}

# -------------------------------------------------------------------------
# 2. PEERING: APPS SPOKE -> HUB PROD
# -------------------------------------------------------------------------
resource "azurerm_virtual_network_peering" "apps_to_hub_prod" {
  provider                     = azurerm.production
  name                         = "peer-apps-hub-prod-swe"
  resource_group_name          = lookup(var.resource_group_names, "rg-netapps-prod-swe", "rg-netapps-prod-swe")
  virtual_network_name         = azurerm_virtual_network.prod["apps_prod"].name
  remote_virtual_network_id    = azurerm_virtual_network.hub_prod["hub_prod"].id

  allow_virtual_network_access = true
  allow_forwarded_traffic      = true
  allow_gateway_transit        = false
  use_remote_gateways          = true

  depends_on = [
    azurerm_subnet.prod,
    azurerm_subnet.hub_prod,
    azurerm_virtual_network_gateway.vpngw
  ]
}

resource "azurerm_virtual_network_peering" "global_hub_to_remote_hub" {
  provider                     = azurerm.connectivity
  count                        = var.enable_global_peering && var.remote_hub_vnet_id != null ? 1 : 0
  name                         = "peer-hub-swe-hub-weu"
  resource_group_name          = local.vnets["hub_prod"].rg_name
  virtual_network_name         = azurerm_virtual_network.hub_prod["hub_prod"].name
  remote_virtual_network_id    = var.remote_hub_vnet_id
  allow_virtual_network_access = true
  allow_forwarded_traffic      = true
  allow_gateway_transit        = true
  use_remote_gateways          = false

  depends_on = [azurerm_subnet.hub_prod, azurerm_virtual_network_gateway.vpngw]
}

# =========================================================================
# CAPA 2: APPLIANCES PERIMETRALES (hub_prod)
# =========================================================================
resource "azurerm_public_ip" "firewall_pip" {
  provider            = azurerm.connectivity
  name                = "pip-firewall-prod-swe-001"
  location            = var.location
  resource_group_name = lookup(var.resource_group_names, "rg-firewall-prod-swe", "rg-firewall-prod-swe")
  allocation_method   = "Static"
  sku                 = "Standard"
  tags                = lookup(var.resource_group_tags, "rg-firewall-prod-swe", var.tags)
}

resource "azurerm_firewall_policy" "fw_policy" {
  provider            = azurerm.connectivity
  name                = "afwp-prod-swe"
  resource_group_name = lookup(var.resource_group_names, "rg-firewall-prod-swe", "rg-firewall-prod-swe")
  location            = var.location
  tags                = lookup(var.resource_group_tags, "rg-firewall-prod-swe", var.tags)
}

resource "azurerm_firewall" "fw" {
  provider            = azurerm.connectivity
  name                = "afw-prod-swe"
  location            = var.location
  resource_group_name = lookup(var.resource_group_names, "rg-nethub-prod-swe", "rg-nethub-prod-swe")
  sku_name            = "AZFW_VNet"
  sku_tier            = "Standard"
  firewall_policy_id  = azurerm_firewall_policy.fw_policy.id
  tags                = lookup(var.resource_group_tags, "rg-nethub-prod-swe", var.tags)

  ip_configuration {
    name                 = "configuration"
    subnet_id            = azurerm_subnet.hub_prod["hub_prod_AzureFirewallSubnet"].id
    public_ip_address_id = azurerm_public_ip.firewall_pip.id
  }
}

resource "azurerm_public_ip" "bastion_pip" {
  provider            = azurerm.connectivity
  name                = "pip-bastion-prod-swe-001"
  location            = var.location
  resource_group_name = lookup(var.resource_group_names, "rg-bastion-prod-swe", "rg-bastion-prod-swe")
  allocation_method   = "Static"
  sku                 = "Standard"
  tags                = lookup(var.resource_group_tags, "rg-bastion-prod-swe", var.tags)
}

resource "azurerm_bastion_host" "bastion" {
  provider            = azurerm.connectivity
  name                = "bastion-prod-swe"
  location            = var.location
  resource_group_name = lookup(var.resource_group_names, "rg-bastion-prod-swe", "rg-bastion-prod-swe")
  sku                 = "Standard"
  tags                = lookup(var.resource_group_tags, "rg-bastion-prod-swe", var.tags)

  ip_configuration {
    name                 = "configuration"
    subnet_id            = azurerm_subnet.hub_prod["hub_prod_AzureBastionSubnet"].id
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
  resource_group_name = lookup(var.resource_group_names, "rg-vpngw-prod-swe", "rg-vpngw-prod-swe")
  allocation_method   = "Static"
  sku                 = "Standard"
  zones               = ["1", "2", "3"]
  tags                = lookup(var.resource_group_tags, "rg-vpngw-prod-swe", var.tags)
}

resource "azurerm_virtual_network_gateway" "vpngw" {
  provider            = azurerm.connectivity
  name                = "vpngw-prod-swe"
  location            = var.location
  resource_group_name = lookup(var.resource_group_names, "rg-nethub-prod-swe", "rg-nethub-prod-swe")

  type     = "Vpn"
  vpn_type = "RouteBased"

  active_active = false
  enable_bgp    = true
  sku           = "VpnGw1AZ"

  ip_configuration {
    name                          = "vpngw-ip-config"
    public_ip_address_id          = azurerm_public_ip.vpngw_pip.id
    private_ip_address_allocation = "Dynamic"
    subnet_id                     = azurerm_subnet.hub_prod["hub_prod_GatewaySubnet"].id
  }

  tags = lookup(var.resource_group_tags, "rg-nethub-prod-swe", var.tags)
}

# =========================================================================
# CAPA 4: APPLICATION GATEWAY
# =========================================================================
resource "azurerm_public_ip" "appgw_pip" {
  provider            = azurerm.connectivity
  name                = "pip-appgw-prod-swe-001"
  location            = var.location
  resource_group_name = lookup(var.resource_group_names, "rg-appgw-prod-swe", "rg-appgw-prod-swe")
  allocation_method   = "Static"
  sku                 = "Standard"
  tags                = lookup(var.resource_group_tags, "rg-appgw-prod-swe", var.tags)
}

resource "azurerm_web_application_firewall_policy" "waf" {
  provider            = azurerm.connectivity
  name                = "waf-agw-prod-swe"
  resource_group_name = lookup(var.resource_group_names, "rg-appgw-prod-swe", "rg-appgw-prod-swe")
  location            = var.location
  tags                = lookup(var.resource_group_tags, "rg-appgw-prod-swe", var.tags)

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
  name                = "agw-hub-prod-swe"
  resource_group_name = lookup(var.resource_group_names, "rg-appgw-prod-swe", "rg-appgw-prod-swe")
  location            = var.location
  tags                = lookup(var.resource_group_tags, "rg-appgw-prod-swe", var.tags)
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
    subnet_id = azurerm_subnet.hub_prod["hub_prod_snet-hub-appgw-prod-swe"].id
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