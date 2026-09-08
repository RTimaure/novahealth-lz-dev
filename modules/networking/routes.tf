# Archivo: modules/networking/routes.tf

# =========================================================================
# TABLAS DE ENRUTAMIENTO (UDR) Y RUTAS DE RED
# Convención Naming C1: rt-<scope>-<env>-<region> (4 segmentos)
# =========================================================================

# -------------------------------------------------------------------------
# 1. HUB MANAGEMENT - PROD (SUSCRIPCIÓN: CONNECTIVITY)
# -------------------------------------------------------------------------
resource "azurerm_route_table" "hub_mngt_prod" {
  provider                      = azurerm.connectivity
  name                          = "rt-mngt-prod-swe"
  location                      = var.location
  resource_group_name           = lookup(var.resource_group_names, "rg-nethub-prod-swe", "rg-nethub-prod-swe")
  bgp_route_propagation_enabled = true
  tags                          = local.platform_tags

  route {
    name                   = "to-internet"
    address_prefix         = "0.0.0.0/0"
    next_hop_type          = "VirtualAppliance"
    next_hop_in_ip_address = local.fw_private_ip
  }

  route {
    name                   = "to-aks"
    address_prefix         = "10.0.4.0/22"
    next_hop_type          = "VirtualAppliance"
    next_hop_in_ip_address = local.fw_private_ip
  }

  route {
    name                   = "to-dataia"
    address_prefix         = "10.0.8.0/23"
    next_hop_type          = "VirtualAppliance"
    next_hop_in_ip_address = local.fw_private_ip
  }

  route {
    name                   = "to-apps"
    address_prefix         = "10.0.10.0/24"
    next_hop_type          = "VirtualAppliance"
    next_hop_in_ip_address = local.fw_private_ip
  }

  route {
    name                   = "to-shared"
    address_prefix         = "10.0.11.0/24"
    next_hop_type          = "VirtualAppliance"
    next_hop_in_ip_address = local.fw_private_ip
  }
}

resource "azurerm_subnet_route_table_association" "hub_mngt_prod" {
  provider       = azurerm.connectivity
  subnet_id      = azurerm_subnet.hub_prod["hub_prod_snet-hub-mngt-prod-swe"].id
  route_table_id = azurerm_route_table.hub_mngt_prod.id
}

# -------------------------------------------------------------------------
# 2. HUB MANAGEMENT - NPROD (SUSCRIPCIÓN: PRODUCTION - rg-netdev-dev-swe)
# -------------------------------------------------------------------------
resource "azurerm_route_table" "hub_mngt_nprod" {
  provider                      = azurerm.production
  name                          = "rt-mngt-nprod-swe"
  location                      = var.location
  resource_group_name           = lookup(var.resource_group_names, "rg-netdev-dev-swe", "rg-netdev-dev-swe")
  bgp_route_propagation_enabled = true
  tags                          = local.platform_tags

  route {
    name                   = "to-internet"
    address_prefix         = "0.0.0.0/0"
    next_hop_type          = "VirtualAppliance"
    next_hop_in_ip_address = local.fw_private_ip
  }

  route {
    name                   = "to-aks"
    address_prefix         = "10.1.4.0/22"
    next_hop_type          = "VirtualAppliance"
    next_hop_in_ip_address = local.fw_private_ip
  }

  route {
    name                   = "to-dataia"
    address_prefix         = "10.1.8.0/23"
    next_hop_type          = "VirtualAppliance"
    next_hop_in_ip_address = local.fw_private_ip
  }

  route {
    name                   = "to-apps"
    address_prefix         = "10.1.10.0/24"
    next_hop_type          = "VirtualAppliance"
    next_hop_in_ip_address = local.fw_private_ip
  }

  route {
    name                   = "to-shared"
    address_prefix         = "10.1.11.0/24"
    next_hop_type          = "VirtualAppliance"
    next_hop_in_ip_address = local.fw_private_ip
  }
}

/*
resource "azurerm_subnet_route_table_association" "hub_mngt_nprod" {
  provider       = azurerm.production
  subnet_id      = azurerm_subnet.hub_nprod["hub_nprod_snet-hub-mngt-nprod-swe"].id
  route_table_id = azurerm_route_table.hub_mngt_nprod.id
}
*/
# -------------------------------------------------------------------------
# 3. AKS SPOKE - PROD (SUSCRIPCIÓN: PRODUCTION)
# -------------------------------------------------------------------------
resource "azurerm_route_table" "aks_prod" {
  provider                      = azurerm.production
  name                          = "rt-aks-prod-swe"
  location                      = var.location
  resource_group_name           = lookup(var.resource_group_names, "rg-netaks-prod-swe", "rg-netaks-prod-swe")
  bgp_route_propagation_enabled = true
  tags                          = local.platform_tags

  route {
    name                   = "to-internet"
    address_prefix         = "0.0.0.0/0"
    next_hop_type          = "VirtualAppliance"
    next_hop_in_ip_address = local.fw_private_ip
  }

  route {
    name                   = "to-hub"
    address_prefix         = "10.0.0.0/22"
    next_hop_type          = "VirtualAppliance"
    next_hop_in_ip_address = local.fw_private_ip
  }

  route {
    name                   = "to-dataia"
    address_prefix         = "10.0.8.0/23"
    next_hop_type          = "VirtualAppliance"
    next_hop_in_ip_address = local.fw_private_ip
  }

  route {
    name                   = "to-apps"
    address_prefix         = "10.0.10.0/24"
    next_hop_type          = "VirtualAppliance"
    next_hop_in_ip_address = local.fw_private_ip
  }

  route {
    name                   = "to-shared"
    address_prefix         = "10.0.11.0/24"
    next_hop_type          = "VirtualAppliance"
    next_hop_in_ip_address = local.fw_private_ip
  }
}

resource "azurerm_subnet_route_table_association" "aks_prod" {
  provider = azurerm.production
  for_each = toset([
    "aks_prod_snet-aks-workload-prod-swe",
    "aks_prod_snet-aks-system-prod-swe",
    "aks_prod_snet-aks-ingress-prod-swe",
    "aks_prod_snet-aks-monitoring-prod-swe"
  ])

  subnet_id      = azurerm_subnet.prod[each.key].id
  route_table_id = azurerm_route_table.aks_prod.id
}

# -------------------------------------------------------------------------
# 4. AKS SPOKE - NPROD (SUSCRIPCIÓN: PRODUCTION - rg-netdev-dev-swe)
# -------------------------------------------------------------------------
resource "azurerm_route_table" "aks_nprod" {
  provider                      = azurerm.production
  name                          = "rt-aks-nprod-swe"
  location                      = var.location
  resource_group_name           = lookup(var.resource_group_names, "rg-netdev-dev-swe", "rg-netdev-dev-swe")
  bgp_route_propagation_enabled = true
  tags                          = local.platform_tags

  route {
    name                   = "to-internet"
    address_prefix         = "0.0.0.0/0"
    next_hop_type          = "VirtualAppliance"
    next_hop_in_ip_address = local.fw_private_ip
  }

  route {
    name                   = "to-hub"
    address_prefix         = "10.1.0.0/22"
    next_hop_type          = "VirtualAppliance"
    next_hop_in_ip_address = local.fw_private_ip
  }

  route {
    name                   = "to-dataia"
    address_prefix         = "10.1.8.0/23"
    next_hop_type          = "VirtualAppliance"
    next_hop_in_ip_address = local.fw_private_ip
  }

  route {
    name                   = "to-apps"
    address_prefix         = "10.1.10.0/24"
    next_hop_type          = "VirtualAppliance"
    next_hop_in_ip_address = local.fw_private_ip
  }

  route {
    name                   = "to-shared"
    address_prefix         = "10.1.11.0/24"
    next_hop_type          = "VirtualAppliance"
    next_hop_in_ip_address = local.fw_private_ip
  }
}

/*resource "azurerm_subnet_route_table_association" "aks_nprod" {
  provider = azurerm.production
  for_each = toset([
    "aks_nprod_snet-aks-workload-nprod-swe",
    "aks_nprod_snet-aks-system-nprod-swe",
    "aks_nprod_snet-aks-ingress-nprod-swe",
    "aks_nprod_snet-aks-monitoring-nprod-swe"
  ])

  subnet_id      = azurerm_subnet.prod[each.key].id
  route_table_id = azurerm_route_table.aks_nprod.id
}
*/
# -------------------------------------------------------------------------
# 5. DATA & IA SPOKE - PROD (SUSCRIPCIÓN: DATA AND IA PLATFORM)
# -------------------------------------------------------------------------
resource "azurerm_route_table" "data_prod" {
  provider                      = azurerm.platform_services
  name                          = "rt-dataai-prod-swe"
  location                      = var.location
  resource_group_name           = lookup(var.resource_group_names, "rg-netdataai-prod-swe", "rg-netdataai-prod-swe")
  bgp_route_propagation_enabled = true
  tags                          = local.platform_tags

  route {
    name                   = "to-internet"
    address_prefix         = "0.0.0.0/0"
    next_hop_type          = "VirtualAppliance"
    next_hop_in_ip_address = local.fw_private_ip
  }

  route {
    name                   = "to-hub"
    address_prefix         = "10.0.0.0/22"
    next_hop_type          = "VirtualAppliance"
    next_hop_in_ip_address = local.fw_private_ip
  }

  route {
    name                   = "to-aks"
    address_prefix         = "10.0.4.0/22"
    next_hop_type          = "VirtualAppliance"
    next_hop_in_ip_address = local.fw_private_ip
  }

  route {
    name                   = "to-apps"
    address_prefix         = "10.0.10.0/24"
    next_hop_type          = "VirtualAppliance"
    next_hop_in_ip_address = local.fw_private_ip
  }

  route {
    name                   = "to-shared"
    address_prefix         = "10.0.11.0/24"
    next_hop_type          = "VirtualAppliance"
    next_hop_in_ip_address = local.fw_private_ip
  }
}

resource "azurerm_subnet_route_table_association" "data_prod" {
  provider = azurerm.platform_services
  for_each = toset([
    "dataai_prod_snet-dataai-analytics-prod-swe",
    "dataai_prod_snet-dataai-compute-prod-swe",
    "dataai_prod_snet-dataai-streaming-prod-swe"
  ])

  subnet_id      = azurerm_subnet.data_prod[each.key].id
  route_table_id = azurerm_route_table.data_prod.id
}

# -------------------------------------------------------------------------
# 6. DATA & IA SPOKE - NPROD (SUSCRIPCIÓN: PRODUCTION - rg-netdev-dev-swe)
# -------------------------------------------------------------------------
resource "azurerm_route_table" "data_nprod" {
  provider                      = azurerm.production
  name                          = "rt-dataai-nprod-swe"
  location                      = var.location
  resource_group_name           = lookup(var.resource_group_names, "rg-netdev-dev-swe", "rg-netdev-dev-swe")
  bgp_route_propagation_enabled = true
  tags                          = local.platform_tags

  route {
    name                   = "to-internet"
    address_prefix         = "0.0.0.0/0"
    next_hop_type          = "VirtualAppliance"
    next_hop_in_ip_address = local.fw_private_ip
  }

  route {
    name                   = "to-hub"
    address_prefix         = "10.1.0.0/22"
    next_hop_type          = "VirtualAppliance"
    next_hop_in_ip_address = local.fw_private_ip
  }

  route {
    name                   = "to-aks"
    address_prefix         = "10.1.4.0/22"
    next_hop_type          = "VirtualAppliance"
    next_hop_in_ip_address = local.fw_private_ip
  }

  route {
    name                   = "to-apps"
    address_prefix         = "10.1.10.0/24"
    next_hop_type          = "VirtualAppliance"
    next_hop_in_ip_address = local.fw_private_ip
  }

  route {
    name                   = "to-shared"
    address_prefix         = "10.1.11.0/24"
    next_hop_type          = "VirtualAppliance"
    next_hop_in_ip_address = local.fw_private_ip
  }
}

/*resource "azurerm_subnet_route_table_association" "data_nprod" {
  provider = azurerm.production
  for_each = toset([
    "dataai_nprod_snet-dataai-analytics-nprod-swe",
    "dataai_nprod_snet-dataai-compute-nprod-swe",
    "dataai_nprod_snet-dataai-streaming-nprod-swe"
  ])

  subnet_id      = azurerm_subnet.data_nprod[each.key].id
  route_table_id = azurerm_route_table.data_nprod.id
}
*/
# -------------------------------------------------------------------------
# 7. APPS SPOKE - PROD (SUSCRIPCIÓN: PRODUCTION)
# -------------------------------------------------------------------------
resource "azurerm_route_table" "apps_prod" {
  provider                      = azurerm.production
  name                          = "rt-apps-prod-swe"
  location                      = var.location
  resource_group_name           = lookup(var.resource_group_names, "rg-netapps-prod-swe", "rg-netapps-prod-swe")
  bgp_route_propagation_enabled = true
  tags                          = local.platform_tags

  route {
    name                   = "to-internet"
    address_prefix         = "0.0.0.0/0"
    next_hop_type          = "VirtualAppliance"
    next_hop_in_ip_address = local.fw_private_ip
  }

  route {
    name                   = "to-hub"
    address_prefix         = "10.0.0.0/22"
    next_hop_type          = "VirtualAppliance"
    next_hop_in_ip_address = local.fw_private_ip
  }

  route {
    name                   = "to-aks"
    address_prefix         = "10.0.4.0/22"
    next_hop_type          = "VirtualAppliance"
    next_hop_in_ip_address = local.fw_private_ip
  }

  route {
    name                   = "to-dataia"
    address_prefix         = "10.0.8.0/23"
    next_hop_type          = "VirtualAppliance"
    next_hop_in_ip_address = local.fw_private_ip
  }

  route {
    name                   = "to-shared"
    address_prefix         = "10.0.11.0/24"
    next_hop_type          = "VirtualAppliance"
    next_hop_in_ip_address = local.fw_private_ip
  }
}

resource "azurerm_subnet_route_table_association" "apps_prod" {
  provider = azurerm.production
  for_each = toset([
    "apps_prod_snet-apps-aca-prod-swe",
    "apps_prod_snet-apps-messaging-prod-swe"
  ])

  subnet_id      = azurerm_subnet.prod[each.key].id
  route_table_id = azurerm_route_table.apps_prod.id
}

# -------------------------------------------------------------------------
# 8. APPS SPOKE - NPROD (SUSCRIPCIÓN: PRODUCTION - rg-netdev-dev-swe)
# -------------------------------------------------------------------------
/*resource "azurerm_route_table" "apps_nprod" {
  provider                      = azurerm.production
  name                          = "rt-apps-nprod-swe"
  location                      = var.location
  resource_group_name           = lookup(var.resource_group_names, "rg-netdev-dev-swe", "rg-netdev-dev-swe")
  bgp_route_propagation_enabled = true
  tags                          = lookup(var.resource_group_tags, "rg-netdev-dev-swe", var.tags)

  route {
    name                   = "to-internet"
    address_prefix         = "0.0.0.0/0"
    next_hop_type          = "VirtualAppliance"
    next_hop_in_ip_address = local.fw_private_ip
  }

  route {
    name                   = "to-hub"
    address_prefix         = "10.1.0.0/22"
    next_hop_type          = "VirtualAppliance"
    next_hop_in_ip_address = local.fw_private_ip
  }

  route {
    name                   = "to-aks"
    address_prefix         = "10.1.4.0/22"
    next_hop_type          = "VirtualAppliance"
    next_hop_in_ip_address = local.fw_private_ip
  }

  route {
    name                   = "to-dataia"
    address_prefix         = "10.1.8.0/23"
    next_hop_type          = "VirtualAppliance"
    next_hop_in_ip_address = local.fw_private_ip
  }

  route {
    name                   = "to-shared"
    address_prefix         = "10.1.11.0/24"
    next_hop_type          = "VirtualAppliance"
    next_hop_in_ip_address = local.fw_private_ip
  }
}

resource "azurerm_subnet_route_table_association" "apps_nprod" {
  provider = azurerm.production
  for_each = toset([
    "apps_nprod_snet-apps-aca-nprod-swe",
    "apps_nprod_snet-apps-messaging-nprod-swe"
  ])

  subnet_id      = azurerm_subnet.prod[each.key].id
  route_table_id = azurerm_route_table.apps_nprod.id
}
*/
# -------------------------------------------------------------------------
# 9. SHARED SERVICES SPOKE - PROD (SUSCRIPCIÓN: DATA_AI)
# -------------------------------------------------------------------------
resource "azurerm_route_table" "shared_prod" {
  provider                      = azurerm.platform_services
  name                          = "rt-shared-prod-swe"
  location                      = var.location
  resource_group_name           = lookup(var.resource_group_names, "rg-netshared-prod-swe", "rg-netshared-prod-swe")
  bgp_route_propagation_enabled = true
  tags                          = local.platform_tags

  route {
    name                   = "to-internet"
    address_prefix         = "0.0.0.0/0"
    next_hop_type          = "VirtualAppliance"
    next_hop_in_ip_address = local.fw_private_ip
  }

  route {
    name                   = "to-hub"
    address_prefix         = "10.0.0.0/22"
    next_hop_type          = "VirtualAppliance"
    next_hop_in_ip_address = local.fw_private_ip
  }

  route {
    name                   = "to-aks"
    address_prefix         = "10.0.4.0/22"
    next_hop_type          = "VirtualAppliance"
    next_hop_in_ip_address = local.fw_private_ip
  }

  route {
    name                   = "to-dataia"
    address_prefix         = "10.0.8.0/23"
    next_hop_type          = "VirtualAppliance"
    next_hop_in_ip_address = local.fw_private_ip
  }

  route {
    name                   = "to-apps"
    address_prefix         = "10.0.10.0/24"
    next_hop_type          = "VirtualAppliance"
    next_hop_in_ip_address = local.fw_private_ip
  }
}

resource "azurerm_subnet_route_table_association" "shared_prod" {
  provider = azurerm.platform_services
  for_each = toset([
    "shared_prod_snet-shared-apim-prod-swe",
    "shared_prod_snet-shared-devops-prod-swe"
  ])

  subnet_id      = azurerm_subnet.shared_prod[each.key].id
  route_table_id = azurerm_route_table.shared_prod.id
}

# -------------------------------------------------------------------------
# 10. SHARED SERVICES SPOKE - NPROD (SUSCRIPCIÓN: PRODUCTION - rg-netdev-dev-swe)
# -------------------------------------------------------------------------
/*resource "azurerm_route_table" "shared_nprod" {
  provider                      = azurerm.production
  name                          = "rt-shared-nprod-swe"
  location                      = var.location
  resource_group_name           = lookup(var.resource_group_names, "rg-netdev-dev-swe", "rg-netdev-dev-swe")
  bgp_route_propagation_enabled = true
  tags                          = lookup(var.resource_group_tags, "rg-netdev-dev-swe", var.tags)

  route {
    name                   = "to-internet"
    address_prefix         = "0.0.0.0/0"
    next_hop_type          = "VirtualAppliance"
    next_hop_in_ip_address = local.fw_private_ip
  }

  route {
    name                   = "to-hub"
    address_prefix         = "10.1.0.0/22"
    next_hop_type          = "VirtualAppliance"
    next_hop_in_ip_address = local.fw_private_ip
  }

  route {
    name                   = "to-aks"
    address_prefix         = "10.1.4.0/22"
    next_hop_type          = "VirtualAppliance"
    next_hop_in_ip_address = local.fw_private_ip
  }

  route {
    name                   = "to-dataia"
    address_prefix         = "10.1.8.0/23"
    next_hop_type          = "VirtualAppliance"
    next_hop_in_ip_address = local.fw_private_ip
  }

  route {
    name                   = "to-apps"
    address_prefix         = "10.1.10.0/24"
    next_hop_type          = "VirtualAppliance"
    next_hop_in_ip_address = local.fw_private_ip
  }
}

resource "azurerm_subnet_route_table_association" "shared_nprod" {
  provider = azurerm.production
  for_each = toset([
    "shared_nprod_snet-shared-apim-nprod-swe",
    "shared_nprod_snet-shared-devops-nprod-swe"
  ])

  subnet_id      = azurerm_subnet.prod[each.key].id
  route_table_id = azurerm_route_table.shared_nprod.id
}
*/