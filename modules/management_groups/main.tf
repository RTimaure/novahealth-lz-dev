# Archivo: modules/management_groups/main.tf

locals {
  root_mg_name = "nh-root"
}

# Nivel 1: Management Group Raíz Corporativo
resource "azurerm_management_group" "root" {
  name         = local.root_mg_name
  display_name = "NovaHealth Global Health Networks"
}

# Nivel 2: Subgrupos Principales (Platform, Landing Zones, Sandbox)
locals {
  level_2_mgs = {
    platform = {
      name         = "nh-platform"
      display_name = "Platform"
    }
    landing_zones = {
      name         = "nh-landing-zones"
      display_name = "Landing Zones"
    }
    sandbox = {
      name         = "nh-sandbox"
      display_name = "Sandbox"
    }
  }
}

resource "azurerm_management_group" "level_2" {
  for_each                   = local.level_2_mgs
  name                       = each.value.name
  display_name               = each.value.display_name
  parent_management_group_id = azurerm_management_group.root.id
}

# Nivel 3: Subgrupos de Platform y Landing Zones
locals {
  level_3_mgs = {
    # Hijos de Platform
    identity = {
      name         = "nh-identity"
      display_name = "Identity"
      parent_key   = "platform"
    }
    management = {
      name         = "nh-management"
      display_name = "Management"
      parent_key   = "platform"
    }
    connectivity = {
      name         = "nh-connectivity"
      display_name = "Conectivity"
      parent_key   = "platform"
    }
    security = {
      name         = "nh-security"
      display_name = "Security"
      parent_key   = "platform"
    }
    # Hijos de Landing Zones
    production = {
      name         = "nh-production"
      display_name = "Production"
      parent_key   = "landing_zones"
    }
    non_production = {
      name         = "nh-non-production"
      display_name = "Non-Production"
      parent_key   = "landing_zones"
    }
  }
}

resource "azurerm_management_group" "level_3" {
  for_each                   = local.level_3_mgs
  name                       = each.value.name
  display_name               = each.value.display_name
  parent_management_group_id = azurerm_management_group.level_2[each.value.parent_key].id
}