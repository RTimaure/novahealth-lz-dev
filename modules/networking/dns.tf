# Archivo: modules/networking/dns.tf

# =========================================================================
# AZURE PRIVATE DNS RESOLVER & PRIVATE DNS ZONES
# =========================================================================

# -------------------------------------------------------------------------
# 1. AZURE PRIVATE DNS RESOLVER (PROD HUB - CONNECTIVITY SUBSCRIPTION)
# Cluster C5: <prefix>-<environment>-<region> (3 segmentos) -> dnspr-prod-swe
# -------------------------------------------------------------------------
resource "azurerm_private_dns_resolver" "hub_dns_resolver" {
  provider            = azurerm.connectivity
  name                = "dnspr-prod-swe"
  location            = var.location
  resource_group_name = lookup(var.resource_group_names, "rg-dns-prod-swe", "rg-dns-prod-swe")
  virtual_network_id  = azurerm_virtual_network.hub_prod["hub_prod"].id
  tags                = lookup(var.resource_group_tags, "rg-dns-prod-swe", var.tags)
}

resource "azurerm_private_dns_resolver_inbound_endpoint" "hub_dns_inbound" {
  provider                = azurerm.connectivity
  name                    = "dnsin-hub-prod-swe"
  private_dns_resolver_id = azurerm_private_dns_resolver.hub_dns_resolver.id
  location                = var.location
  ip_configurations {
    subnet_id                    = azurerm_subnet.hub_prod["hub_prod_snet-hub-dnsin-prod-swe"].id
    private_ip_allocation_method = "Dynamic"
  }
  tags = lookup(var.resource_group_tags, "rg-dns-prod-swe", var.tags)
}

resource "azurerm_private_dns_resolver_outbound_endpoint" "hub_dns_outbound" {
  provider                = azurerm.connectivity
  name                    = "dnsout-hub-prod-swe"
  private_dns_resolver_id = azurerm_private_dns_resolver.hub_dns_resolver.id
  location                = var.location
  subnet_id               = azurerm_subnet.hub_prod["hub_prod_snet-hub-dnsout-prod-swe"].id
  tags                    = lookup(var.resource_group_tags, "rg-dns-prod-swe", var.tags)
}

# -------------------------------------------------------------------------
# 2. PRIVATE DNS ZONES FOR PAAS SERVICES
# -------------------------------------------------------------------------
locals {
  private_dns_zones = toset([
    "privatelink.azurecr.io",
    "privatelink.vaultcore.azure.net",
    "privatelink.database.windows.net",
    "privatelink.documents.azure.com",
    "privatelink.blob.core.windows.net",
    "privatelink.search.windows.net",
    "privatelink.openai.azure.com",
    "privatelink.redis.cache.windows.net",
    "privatelink.servicebus.windows.net",
    "privatelink.azure-api.net"
  ])

  # Lista de claves de VNets locales a enlazar
  local_vnet_keys = toset([
    "hub_prod",
    "dataai_prod",
    "aks_prod",
    "apps_prod",
    "shared_prod"
  ])

  # Mapeo estático conocido antes del apply
  dns_vnet_links_map = {
    for pair in setproduct(local.private_dns_zones, local.local_vnet_keys) :
    "${pair[0]}_${pair[1]}" => {
      zone     = pair[0]
      vnet_key = pair[1]
    }
  }
}

resource "azurerm_private_dns_zone" "dns_zones" {
  provider            = azurerm.connectivity
  for_each            = local.private_dns_zones
  name                = each.value
  resource_group_name = lookup(var.resource_group_names, "rg-dns-prod-swe", "rg-dns-prod-swe")
  tags                = lookup(var.resource_group_tags, "rg-dns-prod-swe", var.tags)
}

resource "azurerm_private_dns_zone_virtual_network_link" "dns_links" {
  provider              = azurerm.connectivity
  for_each              = local.dns_vnet_links_map
  name                  = "link-${replace(each.value.zone, ".", "-")}-${replace(each.value.vnet_key, "_", "-")}"
  resource_group_name   = lookup(var.resource_group_names, "rg-dns-prod-swe", "rg-dns-prod-swe")
  private_dns_zone_name = azurerm_private_dns_zone.dns_zones[each.value.zone].name
  virtual_network_id    = each.value.vnet_key == "hub_prod" ? azurerm_virtual_network.hub_prod["hub_prod"].id : (each.value.vnet_key == "dataai_prod" ? azurerm_virtual_network.data_prod["dataai_prod"].id : (each.value.vnet_key == "shared_prod" ? azurerm_virtual_network.shared_prod["shared_prod"].id : azurerm_virtual_network.prod[each.value.vnet_key].id))
  registration_enabled  = false
  tags                  = lookup(var.resource_group_tags, "rg-dns-prod-swe", var.tags)
}