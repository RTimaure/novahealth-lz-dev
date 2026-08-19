# Archivo: modules/networking/routes.tf

# =========================================================================
# TABLAS DE ENRUTAMIENTO (UDR) Y RUTAS DE RED
# Convención Naming C1: [rt]-[propósito]-[entorno]-[región] (4 segmentos)
# =========================================================================

# -------------------------------------------------------------------------
# 1. HUB MANAGEMENT - PROD (SUSCRIPCIÓN: CONNECTIVITY)
# -------------------------------------------------------------------------
resource "azurerm_route_table" "hub_mngt_prod" {
  provider                      = azurerm.connectivity
  name                          = "rt-mngt-prod-swe"
  location                      = var.location
  resource_group_name           = lookup(var.resource_group_names, "rg-network-hub-prod-swe", "rg-network-hub-prod-swe")
  bgp_route_propagation_enabled = true
  tags                          = var.tags

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
  subnet_id      = azurerm_subnet.hub_prod["hub_prod_snet-mngt-prod-swe-001"].id
  route_table_id = azurerm_route_table.hub_mngt_prod.id
}

# -------------------------------------------------------------------------
# 2. HUB MANAGEMENT - NPROD (SUSCRIPCIÓN: PRODUCTION - rg-network-dev-swe)
# -------------------------------------------------------------------------
resource "azurerm_route_table" "hub_mngt_nprod" {
  provider                      = azurerm.production
  name                          = "rt-mngt-nprod-swe"
  location                      = var.location
  resource_group_name           = lookup(var.resource_group_names, "rg-network-dev-swe", "rg-network-dev-swe")
  bgp_route_propagation_enabled = true
  tags                          = var.tags

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

resource "azurerm_subnet_route_table_association" "hub_mngt_nprod" {
  provider       = azurerm.production
  subnet_id      = azurerm_subnet.hub_nprod["hub_nprod_snet-mngt-nprod-swe-001"].id
  route_table_id = azurerm_route_table.hub_mngt_nprod.id
}

# -------------------------------------------------------------------------
# 3. AKS SPOKE - PROD (SUSCRIPCIÓN: PRODUCTION)
# -------------------------------------------------------------------------
resource "azurerm_route_table" "aks_prod" {
  provider                      = azurerm.production
  name                          = "rt-aks-prod-swe"
  location                      = var.location
  resource_group_name           = lookup(var.resource_group_names, "rg-network-aks-prod-swe", "rg-network-aks-prod-swe")
  bgp_route_propagation_enabled = true
  tags                          = var.tags

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
    "aks_prod_snet-aksworkload-prod-swe-001",
    "aks_prod_snet-akssystem-prod-swe-001",
    "aks_prod_snet-aksingress-prod-swe-001",
    "aks_prod_snet-aksmonitoring-prod-swe-001"
  ])

  subnet_id      = azurerm_subnet.prod[each.key].id
  route_table_id = azurerm_route_table.aks_prod.id
}

# -------------------------------------------------------------------------
# 4. AKS SPOKE - NPROD (SUSCRIPCIÓN: PRODUCTION - rg-network-dev-swe)
# -------------------------------------------------------------------------
resource "azurerm_route_table" "aks_nprod" {
  provider                      = azurerm.production
  name                          = "rt-aks-nprod-swe"
  location                      = var.location
  resource_group_name           = lookup(var.resource_group_names, "rg-network-dev-swe", "rg-network-dev-swe")
  bgp_route_propagation_enabled = true
  tags                          = var.tags

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

resource "azurerm_subnet_route_table_association" "aks_nprod" {
  provider = azurerm.production
  for_each = toset([
    "aks_nprod_snet-aksworkload-nprod-swe-001",
    "aks_nprod_snet-akssystem-nprod-swe-001",
    "aks_nprod_snet-aksingress-nprod-swe-001",
    "aks_nprod_snet-aksmonitoring-nprod-swe-001"
  ])

  subnet_id      = azurerm_subnet.prod[each.key].id
  route_table_id = azurerm_route_table.aks_nprod.id
}

# -------------------------------------------------------------------------
# 5. DATA & IA SPOKE - PROD (SUSCRIPCIÓN: DATA AND IA PLATFORM)
# -------------------------------------------------------------------------
resource "azurerm_route_table" "data_prod" {
  provider                      = azurerm.data_ai
  name                          = "rt-dataai-prod-swe"
  location                      = var.location
  resource_group_name           = lookup(var.resource_group_names, "rg-network-dataai-prod-swe", "rg-network-dataai-prod-swe")
  bgp_route_propagation_enabled = true
  tags                          = var.tags

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
  provider = azurerm.data_ai
  for_each = toset([
    "dataai_prod_snet-dataaianalytics-prod-swe-001",
    "dataai_prod_snet-dataaicompute-prod-swe-001",
    "dataai_prod_snet-dataaistreaming-prod-swe-001"
  ])

  subnet_id      = azurerm_subnet.data_prod[each.key].id
  route_table_id = azurerm_route_table.data_prod.id
}

# -------------------------------------------------------------------------
# 6. DATA & IA SPOKE - NPROD (SUSCRIPCIÓN: PRODUCTION - rg-network-dev-swe)
# -------------------------------------------------------------------------
resource "azurerm_route_table" "data_nprod" {
  provider                      = azurerm.production
  name                          = "rt-dataai-nprod-swe"
  location                      = var.location
  resource_group_name           = lookup(var.resource_group_names, "rg-network-dev-swe", "rg-network-dev-swe")
  bgp_route_propagation_enabled = true
  tags                          = var.tags

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

resource "azurerm_subnet_route_table_association" "data_nprod" {
  provider = azurerm.production
  for_each = toset([
    "dataai_nprod_snet-dataaianalytics-nprod-swe-001",
    "dataai_nprod_snet-dataaicompute-nprod-swe-001",
    "dataai_nprod_snet-dataaistreaming-nprod-swe-001"
  ])

  subnet_id      = azurerm_subnet.data_nprod[each.key].id
  route_table_id = azurerm_route_table.data_nprod.id
}

# -------------------------------------------------------------------------
# 7. APPS SPOKE - PROD (SUSCRIPCIÓN: PRODUCTION)
# -------------------------------------------------------------------------
resource "azurerm_route_table" "apps_prod" {
  provider                      = azurerm.production
  name                          = "rt-apps-prod-swe"
  location                      = var.location
  resource_group_name           = lookup(var.resource_group_names, "rg-network-apps-prod-swe", "rg-network-apps-prod-swe")
  bgp_route_propagation_enabled = true
  tags                          = var.tags

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
    "apps_prod_snet-appsaca-prod-swe-001",
    "apps_prod_snet-appsmessaging-prod-swe-001"
  ])

  subnet_id      = azurerm_subnet.prod[each.key].id
  route_table_id = azurerm_route_table.apps_prod.id
}

# -------------------------------------------------------------------------
# 8. APPS SPOKE - NPROD (SUSCRIPCIÓN: PRODUCTION - rg-network-dev-swe)
# -------------------------------------------------------------------------
resource "azurerm_route_table" "apps_nprod" {
  provider                      = azurerm.production
  name                          = "rt-apps-nprod-swe"
  location                      = var.location
  resource_group_name           = lookup(var.resource_group_names, "rg-network-dev-swe", "rg-network-dev-swe")
  bgp_route_propagation_enabled = true
  tags                          = var.tags

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
    "apps_nprod_snet-appsaca-nprod-swe-001",
    "apps_nprod_snet-appsmessaging-nprod-swe-001"
  ])

  subnet_id      = azurerm_subnet.prod[each.key].id
  route_table_id = azurerm_route_table.apps_nprod.id
}

# -------------------------------------------------------------------------
# 9. SHARED SERVICES SPOKE - PROD (SUSCRIPCIÓN: PRODUCTION)
# -------------------------------------------------------------------------
resource "azurerm_route_table" "shared_prod" {
  provider                      = azurerm.data_ai
  name                          = "rt-shared-prod-swe"
  location                      = var.location
  resource_group_name           = lookup(var.resource_group_names, "rg-network-shared-prod-swe", "rg-network-shared-prod-swe")
  bgp_route_propagation_enabled = true
  tags                          = var.tags

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
  provider = azurerm.data_ai
  for_each = toset([
    "shared_prod_snet-sharedapim-prod-swe-001",
    "shared_prod_snet-shareddevops-prod-swe-001"
  ])

  subnet_id      = azurerm_subnet.shared_prod[each.key].id
  route_table_id = azurerm_route_table.shared_prod.id
}

# -------------------------------------------------------------------------
# 10. SHARED SERVICES SPOKE - NPROD (SUSCRIPCIÓN: PRODUCTION - rg-network-dev-swe)
# -------------------------------------------------------------------------
resource "azurerm_route_table" "shared_nprod" {
  provider                      = azurerm.production
  name                          = "rt-shared-nprod-swe"
  location                      = var.location
  resource_group_name           = lookup(var.resource_group_names, "rg-network-dev-swe", "rg-network-dev-swe")
  bgp_route_propagation_enabled = true
  tags                          = var.tags

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
    "shared_nprod_snet-sharedapim-nprod-swe-001",
    "shared_nprod_snet-shareddevops-nprod-swe-001"
  ])

  subnet_id      = azurerm_subnet.prod[each.key].id
  route_table_id = azurerm_route_table.shared_nprod.id
}
