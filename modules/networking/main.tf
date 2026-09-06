# Archivo: modules/networking/main.tf

locals {
  fw_private_ip = "10.0.2.4"

  # -------------------------------------------------------------------------
  # CATÁLOGO DE GOBERNANZA (Alineado con tabla de FinOps y Tags)
  # -------------------------------------------------------------------------
  workload_profiles = {
    platform = {
      costCenter = "CC-001"
      workload   = "platform"
    }
    hospital_systems = {
      costCenter = "CC-005"
      workload   = "hospital-systems"
    }
    telemedicine = {
      costCenter = "CC-006"
      workload   = "telemedicine"
    }
    clinical_ai = {
      costCenter = "CC-007"
      workload   = "clinical-ai"
    }
    shared_services = {
      costCenter = "CC-008"
      workload   = "shared-services"
    }
  }

  vnets = {
    hub_prod = {
      name          = "vnet-hub-prod-swe"
      rg_name       = lookup(var.resource_group_names, "rg-nethub-prod-swe", "rg-nethub-prod-swe")
      address_space = ["10.0.0.0/22"]
      profile       = "platform"
      env           = "prod"
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
      profile       = "platform"
      env           = "prod"
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
      profile       = "platform"
      env           = "prod"
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
      profile       = "platform"
      env           = "prod"
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
      profile       = "platform"
      env           = "prod"
      subnets = {
        "snet-shared-pe-prod-swe"     = "10.0.11.0/25"
        "snet-shared-apim-prod-swe"   = "10.0.11.128/26"
        "snet-shared-devops-prod-swe" = "10.0.11.192/27"
      }
    }
    onprem_prod = {
      name          = "vnet-onprem-prod-swe"
      rg_name       = lookup(var.resource_group_names, "rg-nethub-prod-swe", "rg-nethub-prod-swe")
      address_space = ["172.16.0.0/16"]
      profile       = "platform"
      env           = "prod"
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
        profile     = vnet.profile
        env         = vnet.env
      }
    ]
  ])

  subnet_map = {
    for s in local.subnet_list : "${s.vnet_key}_${s.subnet_name}" => s
  }

  # Splits por suscripción
  hub_vnets_prod      = { for k, v in local.vnets : k => v if k == "hub_prod" || k == "onprem_prod" }
  hub_subnets_prod    = { for k, v in local.subnet_map : k => v if v.vnet_key == "hub_prod" || v.vnet_key == "onprem_prod" }
  data_vnets_prod     = { for k, v in local.vnets : k => v if k == "dataai_prod" }
  data_subnets_prod   = { for k, v in local.subnet_map : k => v if v.vnet_key == "dataai_prod" }
  prod_vnets          = { for k, v in local.vnets : k => v if length(regexall("^(aks|apps)", k)) > 0 || k == "shared_nprod" }
  prod_subnets        = { for k, v in local.subnet_map : k => v if length(regexall("^(aks|apps)", v.vnet_key)) > 0 || v.vnet_key == "shared_nprod" }
  shared_vnets_prod   = { for k, v in local.vnets : k => v if k == "shared_prod" }
  shared_subnets_prod = { for k, v in local.subnet_map : k => v if v.vnet_key == "shared_prod" }
  prod_vnets_envprod  = { for k, v in local.prod_vnets : k => v if length(regexall("nprod", k)) == 0 }

  # Tags base para componentes de plataforma transversales
  platform_tags = merge(
    var.tags,
    local.workload_profiles.platform,
    { environment = "prod" }
  )
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

  tags = merge(
    var.tags,
    local.workload_profiles[each.value.profile],
    { environment = each.value.env }
  )
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

  tags = merge(
    var.tags,
    local.workload_profiles[each.value.profile],
    { environment = each.value.env }
  )
}

resource "azurerm_subnet_network_security_group_association" "hub_prod" {
  provider                  = azurerm.connectivity
  for_each                  = { for k, v in local.hub_subnets_prod : k => v if !contains(["AzureFirewallSubnet", "GatewaySubnet"], v.subnet_name) }
  subnet_id                 = azurerm_subnet.hub_prod[each.key].id
  network_security_group_id = azurerm_network_security_group.hub_nsgs_prod[each.key].id

  depends_on = [azurerm_network_security_rule.hub_rules_prod]
}

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

  tags = merge(
    var.tags,
    local.workload_profiles[each.value.profile],
    { environment = each.value.env }
  )
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

  tags = merge(
    var.tags,
    local.workload_profiles[each.value.profile],
    { environment = each.value.env }
  )
}

resource "azurerm_subnet_network_security_group_association" "data_prod" {
  provider                  = azurerm.data_ai
  for_each                  = local.data_subnets_prod
  subnet_id                 = azurerm_subnet.data_prod[each.key].id
  network_security_group_id = azurerm_network_security_group.data_nsgs_prod[each.key].id

  depends_on = [azurerm_network_security_rule.data_ai_rules_prod]
}

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

  tags = merge(
    var.tags,
    local.workload_profiles[each.value.profile],
    { environment = each.value.env }
  )
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

  tags = merge(
    var.tags,
    local.workload_profiles[each.value.profile],
    { environment = each.value.env }
  )
}

resource "azurerm_subnet_network_security_group_association" "shared_prod" {
  provider                  = azurerm.data_ai
  for_each                  = local.shared_subnets_prod
  subnet_id                 = azurerm_subnet.shared_prod[each.key].id
  network_security_group_id = azurerm_network_security_group.shared_nsgs_prod[each.key].id

  depends_on = [azurerm_network_security_rule.prod_rules]
}

# =========================================================================
# DOMINIO PRODUCCIÓN (aks/apps) — SUSCRIPCIÓN PRODUCTION
# =========================================================================
resource "azurerm_virtual_network" "prod" {
  provider            = azurerm.production
  for_each            = local.prod_vnets
  name                = each.value.name
  location            = var.location
  resource_group_name = each.value.rg_name
  address_space       = each.value.address_space

  tags = merge(
    var.tags,
    local.workload_profiles[each.value.profile],
    { environment = each.value.env }
  )
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

  tags = merge(
    var.tags,
    local.workload_profiles[each.value.profile],
    { environment = each.value.env }
  )
}

resource "azurerm_subnet_network_security_group_association" "prod" {
  provider                  = azurerm.production
  for_each                  = local.prod_subnets
  subnet_id                 = azurerm_subnet.prod[each.key].id
  network_security_group_id = azurerm_network_security_group.prod_nsgs[each.key].id

  depends_on = [azurerm_network_security_rule.prod_rules]
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
  depends_on                   = [azurerm_subnet.prod, azurerm_subnet.hub_prod, azurerm_virtual_network_gateway.vpngw]
}

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
  depends_on                   = [azurerm_subnet.prod, azurerm_subnet.hub_prod, azurerm_virtual_network_gateway.vpngw]
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
  depends_on                   = [azurerm_subnet.hub_prod, azurerm_virtual_network_gateway.vpngw]
}

# =========================================================================
# CAPA 2: APPLIANCES PERIMETRALES (hub_prod) — CC-001 (Platform)
# =========================================================================
resource "azurerm_public_ip" "firewall_pip" {
  provider            = azurerm.connectivity
  name                = "pip-firewall-prod-swe-001"
  location            = var.location
  resource_group_name = lookup(var.resource_group_names, "rg-firewall-prod-swe", "rg-firewall-prod-swe")
  allocation_method   = "Static"
  sku                 = "Standard"
  tags                = local.platform_tags
}

resource "azurerm_firewall_policy" "fw_policy" {
  provider            = azurerm.connectivity
  name                = "afwp-prod-swe"
  resource_group_name = lookup(var.resource_group_names, "rg-firewall-prod-swe", "rg-firewall-prod-swe")
  location            = var.location
  tags                = local.platform_tags
}

resource "azurerm_firewall" "fw" {
  provider            = azurerm.connectivity
  name                = "afw-prod-swe"
  location            = var.location
  resource_group_name = lookup(var.resource_group_names, "rg-nethub-prod-swe", "rg-nethub-prod-swe")
  sku_name            = "AZFW_VNet"
  sku_tier            = "Standard"
  firewall_policy_id  = azurerm_firewall_policy.fw_policy.id
  tags                = local.platform_tags

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
  tags                = local.platform_tags
}

resource "azurerm_bastion_host" "bastion" {
  provider            = azurerm.connectivity
  name                = "bastion-prod-swe"
  location            = var.location
  resource_group_name = lookup(var.resource_group_names, "rg-bastion-prod-swe", "rg-bastion-prod-swe")
  sku                 = "Standard"
  tags                = local.platform_tags

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
  tags                = local.platform_tags
}

resource "azurerm_virtual_network_gateway" "vpngw" {
  provider            = azurerm.connectivity
  name                = "vpngw-prod-swe"
  location            = var.location
  resource_group_name = lookup(var.resource_group_names, "rg-nethub-prod-swe", "rg-nethub-prod-swe")
  type                = "Vpn"
  vpn_type            = "RouteBased"
  active_active       = false
  enable_bgp          = true
  sku                 = "VpnGw1AZ"

  ip_configuration {
    name                          = "vpngw-ip-config"
    public_ip_address_id          = azurerm_public_ip.vpngw_pip.id
    private_ip_address_allocation = "Dynamic"
    subnet_id                     = azurerm_subnet.hub_prod["hub_prod_GatewaySubnet"].id
  }

  tags = local.platform_tags
}

# =========================================================================
# CAPA 4: APPLICATION GATEWAY — CC-001 (Platform)
# =========================================================================
resource "azurerm_public_ip" "appgw_pip" {
  provider            = azurerm.connectivity
  name                = "pip-appgw-prod-swe-001"
  location            = var.location
  resource_group_name = lookup(var.resource_group_names, "rg-appgw-prod-swe", "rg-appgw-prod-swe")
  allocation_method   = "Static"
  sku                 = "Standard"
  tags                = local.platform_tags
}

resource "azurerm_web_application_firewall_policy" "waf" {
  provider            = azurerm.connectivity
  name                = "waf-agw-prod-swe"
  resource_group_name = lookup(var.resource_group_names, "rg-appgw-prod-swe", "rg-appgw-prod-swe")
  location            = var.location
  tags                = local.platform_tags

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
  tags                = local.platform_tags
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