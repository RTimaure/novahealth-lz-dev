# Archivo: modules/networking/dns.tf

# =========================================================================
# AZURE PRIVATE DNS RESOLVER & PRIVATE DNS ZONES
# =========================================================================

# -------------------------------------------------------------------------
# 1. AZURE PRIVATE DNS RESOLVER (PROD HUB - CONNECTIVITY SUBSCRIPTION)
# -------------------------------------------------------------------------
resource "azurerm_private_dns_resolver" "hub_dns_resolver" {
  provider            = azurerm.connectivity
  name                = "dnspr-hub-prod-swe"
  location            = var.location
  resource_group_name = lookup(var.resource_group_names, "rg-dns-prod-swe", "rg-dns-prod-swe")
  virtual_network_id  = azurerm_virtual_network.hub_prod["hub_prod"].id
  tags                = var.tags
}

resource "azurerm_private_dns_resolver_inbound_endpoint" "hub_dns_inbound" {
  provider                = azurerm.connectivity
  name                    = "dnsin-hub-prod-swe"
  private_dns_resolver_id = azurerm_private_dns_resolver.hub_dns_resolver.id
  location                = var.location
  ip_configurations {
    subnet_id                    = azurerm_subnet.hub_prod["hub_prod_snet-dnsin-prod-swe-001"].id
    private_ip_allocation_method = "Dynamic"
  }
  tags                    = var.tags
}

resource "azurerm_private_dns_resolver_outbound_endpoint" "hub_dns_outbound" {
  provider                = azurerm.connectivity
  name                    = "dnsout-hub-prod-swe"
  private_dns_resolver_id = azurerm_private_dns_resolver.hub_dns_resolver.id
  location                = var.location
  subnet_id               = azurerm_subnet.hub_prod["hub_prod_snet-dnsout-prod-swe-001"].id
  tags                    = var.tags
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

  vnets_to_link = merge(
    { for k, v in azurerm_virtual_network.hub_prod : k => v.id },
    { for k, v in azurerm_virtual_network.data_prod : k => v.id },
    { for k, v in azurerm_virtual_network.prod : k => v.id }
  )

  dns_vnet_links = flatten([
    for zone in local.private_dns_zones : [
      for vkey, vid in local.vnets_to_link : {
        link_key = "${zone}_${vkey}"
        zone     = zone
        vnet_key = vkey
        vnet_id  = vid
      }
    ]
  ])

  dns_vnet_links_map = { for link in local.dns_vnet_links : link.link_key => link }
}

resource "azurerm_private_dns_zone" "dns_zones" {
  provider            = azurerm.connectivity
  for_each            = local.private_dns_zones
  name                = each.value
  resource_group_name = lookup(var.resource_group_names, "rg-dns-prod-swe", "rg-dns-prod-swe")
  tags                = var.tags
}

resource "azurerm_private_dns_zone_virtual_network_link" "dns_links" {
  provider              = azurerm.connectivity
  for_each              = local.dns_vnet_links_map
  name                  = "link-${replace(each.value.zone, ".", "-")}-${each.value.vnet_key}"
  resource_group_name   = lookup(var.resource_group_names, "rg-dns-prod-swe", "rg-dns-prod-swe")
  private_dns_zone_name = azurerm_private_dns_zone.dns_zones[each.value.zone].name
  virtual_network_id    = each.value.vnet_id
  registration_enabled  = false
  tags                  = var.tags
}
