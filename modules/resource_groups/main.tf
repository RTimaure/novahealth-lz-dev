# Archivo: modules/resource_groups/main.tf

locals {
  project_name      = "NovaHealth-LandingZone"
  selected_location = var.deployment_scope == "dr" ? var.dr_location : var.primary_location

  # =========================================================================
  # 1. SUSCRIPCIÓN: CONNECTIVITY
  # =========================================================================
  connectivity_rgs = {
    # Sweden Central (Primary) - 4 segmentos exactos
    "rg-mgmtvm-prod-swe"   = { loc = var.primary_location, env = "prod", owner = "grp-novahealth-ops-team", workload = "platformshared-services", crit = "Medium", cc = "CC-004" }
    "rg-nethub-prod-swe"   = { loc = var.primary_location, env = "prod", owner = "grp-novahealth-network-team", workload = "platformshared-services", crit = "Critical", cc = "CC-001" }
    "rg-firewall-prod-swe" = { loc = var.primary_location, env = "prod", owner = "grp-novahealth-security-team", workload = "security-compliance", crit = "Critical", cc = "CC-001" }
    "rg-vpngw-prod-swe"    = { loc = var.primary_location, env = "prod", owner = "grp-novahealth-network-team", workload = "platformshared-services", crit = "High", cc = "CC-001" }
    "rg-bastion-prod-swe"  = { loc = var.primary_location, env = "prod", owner = "grp-novahealth-ops-team", workload = "platformshared-services", crit = "High", cc = "CC-001" }
    "rg-dns-prod-swe"      = { loc = var.primary_location, env = "prod", owner = "grp-novahealth-network-team", workload = "platformshared-services", crit = "Critical", cc = "CC-001" }
    "rg-appgw-prod-swe"    = { loc = var.primary_location, env = "prod", owner = "grp-novahealth-network-team", workload = "platformshared-services", crit = "High", cc = "CC-001" }

    # West Europe (DR) - 4 segmentos exactos
    "rg-nethub-dr-weu"   = { loc = var.dr_location, env = "dr", owner = "grp-novahealth-network-team", workload = "platformshared-services", crit = "Critical", cc = "CC-001" }
    "rg-firewall-dr-weu" = { loc = var.dr_location, env = "dr", owner = "grp-novahealth-security-team", workload = "security-compliance", crit = "Critical", cc = "CC-001" }
    "rg-vpngw-dr-weu"    = { loc = var.dr_location, env = "dr", owner = "grp-novahealth-network-team", workload = "platformshared-services", crit = "High", cc = "CC-001" }
    "rg-bastion-dr-weu"  = { loc = var.dr_location, env = "dr", owner = "grp-novahealth-ops-team", workload = "platformshared-services", crit = "High", cc = "CC-001" }
    "rg-dns-dr-weu"      = { loc = var.dr_location, env = "dr", owner = "grp-novahealth-network-team", workload = "platformshared-services", crit = "Critical", cc = "CC-001" }
    "rg-appgw-dr-weu"    = { loc = var.dr_location, env = "dr", owner = "grp-novahealth-network-team", workload = "platformshared-services", crit = "High", cc = "CC-001" }
  }

  # =========================================================================
  # 2. SUSCRIPCIÓN: IDENTITY
  # =========================================================================
  identity_rgs = {
    "rg-identity-prod-swe" = { loc = var.primary_location, env = "prod", owner = "grp-novahealth-security-team", workload = "security-compliance", crit = "Critical", cc = "CC-002" }
    "rg-identity-dr-weu"   = { loc = var.dr_location, env = "dr", owner = "grp-novahealth-security-team", workload = "security-compliance", crit = "Critical", cc = "CC-002" }
  }

  # =========================================================================
  # 3. SUSCRIPCIÓN: MANAGEMENT
  # =========================================================================
  management_rgs = {

    "rg-monitoring-prod-swe" = { loc = var.primary_location, env = "prod", owner = "grp-novahealth-ops-team", workload = "platformshared-services", crit = "High", cc = "CC-004" }
    "rg-automation-prod-swe" = { loc = var.primary_location, env = "prod", owner = "grp-novahealth-ops-team", workload = "platformshared-services", crit = "High", cc = "CC-004" }
    "rg-backup-prod-swe"     = { loc = var.primary_location, env = "prod", owner = "grp-novahealth-ops-team", workload = "platformshared-services", crit = "Critical", cc = "CC-004" }
    "rg-sandbox-dev-swe"     = { loc = var.primary_location, env = "dev", owner = "grp-novahealth-dev-team", workload = "platformshared-services", crit = "Low", cc = "CC-009" }

    "rg-mgmtvm-dr-weu"     = { loc = var.dr_location, env = "dr", owner = "grp-novahealth-ops-team", workload = "platformshared-services", crit = "Medium", cc = "CC-004" }
    "rg-monitoring-dr-weu" = { loc = var.dr_location, env = "dr", owner = "grp-novahealth-ops-team", workload = "platformshared-services", crit = "High", cc = "CC-004" }
    "rg-automation-dr-weu" = { loc = var.dr_location, env = "dr", owner = "grp-novahealth-ops-team", workload = "platformshared-services", crit = "High", cc = "CC-004" }
    "rg-backup-dr-weu"     = { loc = var.dr_location, env = "dr", owner = "grp-novahealth-ops-team", workload = "platformshared-services", crit = "Critical", cc = "CC-004" }
    "rg-sandbox-dev-weu"   = { loc = var.dr_location, env = "dr", owner = "grp-novahealth-dev-team", workload = "platformshared-services", crit = "Low", cc = "CC-009" }
  }

  # =========================================================================
  # 4. SUSCRIPCIÓN: PRODUCTION
  # =========================================================================
  production_rgs = {
    "rg-netaks-prod-swe"  = { loc = var.primary_location, env = "prod", owner = "grp-novahealth-network-team", workload = "hospital-systems", crit = "High", cc = "CC-005" }
    "rg-aks-prod-swe"     = { loc = var.primary_location, env = "prod", owner = "grp-novahealth-ops-team", workload = "hospital-systems", crit = "High", cc = "CC-005" }
    "rg-netapps-prod-swe" = { loc = var.primary_location, env = "prod", owner = "grp-novahealth-network-team", workload = "telemedicine", crit = "High", cc = "CC-006" }
    "rg-apps-prod-swe"    = { loc = var.primary_location, env = "prod", owner = "grp-novahealth-ops-team", workload = "telemedicine", crit = "High", cc = "CC-006" }
    "rg-shared-prod-swe"  = { loc = var.primary_location, env = "prod", owner = "grp-novahealth-it-core", workload = "platformshared-services", crit = "High", cc = "CC-008" }
    "rg-rag-prod-swe"     = { loc = var.primary_location, env = "prod", owner = "grp-novahealth-clinicalai-team", workload = "clinical-ai", crit = "High", cc = "CC-007" }

    "rg-netdev-dev-swe"         = { loc = var.primary_location, env = "dev", owner = "grp-novahealth-network-team", workload = "hospital-systems", crit = "Low", cc = "CC-005" }
    "rg-aks-dev-swe"            = { loc = var.primary_location, env = "dev", owner = "grp-novahealth-dev-team", workload = "hospital-systems", crit = "Low", cc = "CC-005" }
    "rg-apps-dev-swe"           = { loc = var.primary_location, env = "dev", owner = "grp-novahealth-dev-team", workload = "telemedicine", crit = "Low", cc = "CC-006" }
    "rg-sharedservices-dev-swe" = { loc = var.primary_location, env = "dev", owner = "grp-novahealth-it-core", workload = "platformshared-services", crit = "Low", cc = "CC-008" }

    "rg-netqa-qa-swe"  = { loc = var.primary_location, env = "qa", owner = "grp-novahealth-network-team", workload = "hospital-systems", crit = "Medium", cc = "CC-005" }
    "rg-apps-qa-swe"   = { loc = var.primary_location, env = "qa", owner = "grp-novahealth-qa-team", workload = "telemedicine", crit = "Medium", cc = "CC-006" }
    "rg-shared-qa-swe" = { loc = var.primary_location, env = "qa", owner = "grp-novahealth-it-core", workload = "platformshared-services", crit = "Medium", cc = "CC-008" }

    "rg-netaks-dr-weu"  = { loc = var.dr_location, env = "dr", owner = "grp-novahealth-network-team", workload = "hospital-systems", crit = "High", cc = "CC-005" }
    "rg-aks-dr-weu"     = { loc = var.dr_location, env = "dr", owner = "grp-novahealth-ops-team", workload = "hospital-systems", crit = "High", cc = "CC-005" }
    "rg-netapps-dr-weu" = { loc = var.dr_location, env = "dr", owner = "grp-novahealth-network-team", workload = "telemedicine", crit = "High", cc = "CC-006" }
    "rg-apps-dr-weu"    = { loc = var.dr_location, env = "dr", owner = "grp-novahealth-ops-team", workload = "telemedicine", crit = "High", cc = "CC-006" }
    "rg-shared-dr-weu"  = { loc = var.dr_location, env = "dr", owner = "grp-novahealth-it-core", workload = "platformshared-services", crit = "High", cc = "CC-008" }
    "rg-rag-dr-weu"     = { loc = var.dr_location, env = "dr", owner = "grp-novahealth-clinicalai-team", workload = "clinical-ai", crit = "High", cc = "CC-007" }
  }

  # =========================================================================
  # 5. SUSCRIPCIÓN: PLATFORM SERVICES
  # =========================================================================
  dataia_rgs = {
    "rg-netshared-prod-swe"      = { loc = var.primary_location, env = "prod", owner = "grp-novahealth-network-team", workload = "platformshared-services", crit = "High", cc = "CC-008" }
    "rg-sharedservices-prod-swe" = { loc = var.primary_location, env = "prod", owner = "grp-novahealth-it-core", workload = "platformshared-services", crit = "High", cc = "CC-008" }
    "rg-netdataai-prod-swe"      = { loc = var.primary_location, env = "prod", owner = "grp-novahealth-network-team", workload = "clinical-ai", crit = "Critical", cc = "CC-007" }
    "rg-dataai-prod-swe"         = { loc = var.primary_location, env = "prod", owner = "grp-novahealth-clinicalai-team", workload = "clinical-ai", crit = "Critical", cc = "CC-007" }

    "rg-dataai-dev-swe" = { loc = var.primary_location, env = "dev", owner = "grp-novahealth-clinicalai-team", workload = "clinical-ai", crit = "Low", cc = "CC-007" }
    "rg-dataai-qa-swe"  = { loc = var.primary_location, env = "qa", owner = "grp-novahealth-clinicalai-team", workload = "clinical-ai", crit = "Medium", cc = "CC-007" }

    "rg-netshared-dr-weu"      = { loc = var.dr_location, env = "dr", owner = "grp-novahealth-network-team", workload = "platformshared-services", crit = "High", cc = "CC-008" }
    "rg-sharedservices-dr-weu" = { loc = var.dr_location, env = "dr", owner = "grp-novahealth-it-core", workload = "platformshared-services", crit = "High", cc = "CC-008" }
    "rg-netdataai-dr-weu"      = { loc = var.dr_location, env = "dr", owner = "grp-novahealth-network-team", workload = "clinical-ai", crit = "Critical", cc = "CC-007" }
    "rg-dataai-dr-weu"         = { loc = var.dr_location, env = "dr", owner = "grp-novahealth-clinicalai-team", workload = "clinical-ai", crit = "Critical", cc = "CC-007" }
  }
}

resource "azurerm_resource_group" "connectivity" {
  provider = azurerm.connectivity
  for_each = { for k, v in local.connectivity_rgs : k => v if v.loc == local.selected_location }
  name     = each.key
  location = each.value.loc
  tags = {
    environmentType = each.value.loc == var.primary_location ? "primary" : "dr"
    environment     = each.value.env
    region          = each.value.loc == var.primary_location ? "SwedenCentral" : "WestEurope"
    owner           = each.value.owner
    costCenter      = each.value.cc
    project         = local.project_name
    workload        = each.value.workload
    criticality     = each.value.crit
  }
}

resource "azurerm_resource_group" "identity" {
  provider = azurerm.identity
  for_each = { for k, v in local.identity_rgs : k => v if v.loc == local.selected_location }
  name     = each.key
  location = each.value.loc
  tags = {
    environmentType = each.value.loc == var.primary_location ? "primary" : "dr"
    environment     = each.value.env
    region          = each.value.loc == var.primary_location ? "SwedenCentral" : "WestEurope"
    owner           = each.value.owner
    costCenter      = each.value.cc
    project         = local.project_name
    workload        = each.value.workload
    criticality     = each.value.crit
  }
}

resource "azurerm_resource_group" "management" {
  provider = azurerm.management
  for_each = { for k, v in local.management_rgs : k => v if v.loc == local.selected_location }
  name     = each.key
  location = each.value.loc
  tags = {
    environmentType = each.value.loc == var.primary_location ? "primary" : "dr"
    environment     = each.value.env
    region          = each.value.loc == var.primary_location ? "SwedenCentral" : "WestEurope"
    owner           = each.value.owner
    costCenter      = each.value.cc
    project         = local.project_name
    workload        = each.value.workload
    criticality     = each.value.crit
  }
}

resource "azurerm_resource_group" "production" {
  provider = azurerm.production
  for_each = { for k, v in local.production_rgs : k => v if v.loc == local.selected_location }
  name     = each.key
  location = each.value.loc
  tags = {
    environmentType = each.value.loc == var.primary_location ? "primary" : "dr"
    environment     = each.value.env
    region          = each.value.loc == var.primary_location ? "SwedenCentral" : "WestEurope"
    owner           = each.value.owner
    costCenter      = each.value.cc
    project         = local.project_name
    workload        = each.value.workload
    criticality     = each.value.crit
  }
}

resource "azurerm_resource_group" "platform_services" {
  provider = azurerm.platform_services
  for_each = { for k, v in local.dataia_rgs : k => v if v.loc == local.selected_location }
  name     = each.key
  location = each.value.loc
  tags = {
    environmentType = each.value.loc == var.primary_location ? "primary" : "dr"
    environment     = each.value.env
    region          = each.value.loc == var.primary_location ? "SwedenCentral" : "WestEurope"
    owner           = each.value.owner
    costCenter      = each.value.cc
    project         = local.project_name
    workload        = each.value.workload
    criticality     = each.value.crit
  }
}