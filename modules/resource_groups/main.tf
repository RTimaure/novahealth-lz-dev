# Archivo: modules/resource_groups/main.tf

locals {
  project_name = "NovaHealth-LandingZone"
  selected_location = var.deployment_scope == "dr" ? var.dr_location : var.primary_location

    # =========================================================================
  # 1. SUSCRIPCIÓN: CONNECTIVITY
  # =========================================================================
  connectivity_rgs = {
        # Sweden Central (Primary)
    "rg-network-hub-prod-swe" = { loc = var.primary_location, env = "prod", owner = "grp-novahealth-network-team",  bu = "HospitalSystems", crit = "Critical", cc = "IT-001" }
    "rg-firewall-prod-swe"    = { loc = var.primary_location, env = "prod", owner = "grp-novahealth-security-team", bu = "Security",        crit = "Critical", cc = "IT-002" }
    "rg-vpngw-prod-swe"       = { loc = var.primary_location, env = "prod", owner = "grp-novahealth-network-team",  bu = "HospitalSystems", crit = "High",     cc = "IT-001" }
    "rg-bastion-prod-swe"     = { loc = var.primary_location, env = "prod", owner = "grp-novahealth-ops-team",      bu = "Security",        crit = "High",     cc = "IT-002" }
    "rg-dns-prod-swe"         = { loc = var.primary_location, env = "prod", owner = "grp-novahealth-network-team",  bu = "HospitalSystems", crit = "Critical", cc = "IT-001" }
    "rg-appgw-prod-swe"       = { loc = var.primary_location, env = "prod", owner = "grp-novahealth-network-team",  bu = "HospitalSystems", crit = "High",     cc = "IT-001" }
    "rg-mgmt-vm-prod-swe"     = { loc = var.primary_location, env = "prod", owner = "grp-novahealth-ops-team",      bu = "FinOps",          crit = "Medium",   cc = "IT-004" }

    # West Europe (DR)
    "rg-network-hub-dr-weu"   = { loc = var.dr_location,      env = "dr",   owner = "grp-novahealth-network-team",  bu = "HospitalSystems", crit = "Critical", cc = "IT-001" }
    "rg-firewall-dr-weu"      = { loc = var.dr_location,      env = "dr",   owner = "grp-novahealth-security-team", bu = "Security",        crit = "Critical", cc = "IT-002" }
    "rg-vpngw-dr-weu"         = { loc = var.dr_location,      env = "dr",   owner = "grp-novahealth-network-team",  bu = "HospitalSystems", crit = "High",     cc = "IT-001" }
        "rg-bastion-dr-weu"       = { loc = var.dr_location,      env = "dr",   owner = "grp-novahealth-ops-team",      bu = "Security",        crit = "High",     cc = "IT-002" }
    "rg-dns-dr-weu"           = { loc = var.dr_location,      env = "dr",   owner = "grp-novahealth-network-team",  bu = "HospitalSystems", crit = "Critical", cc = "IT-001" }
    "rg-appgw-dr-weu"         = { loc = var.dr_location,      env = "dr",   owner = "grp-novahealth-network-team",  bu = "HospitalSystems", crit = "High",     cc = "IT-001" }
    "rg-mgmt-vm-dr-weu"       = { loc = var.dr_location,      env = "dr",   owner = "grp-novahealth-ops-team",      bu = "FinOps",          crit = "Medium",   cc = "IT-004" }
  }


  # =========================================================================
  # 2. SUSCRIPCIÓN: IDENTITY
  # =========================================================================
    identity_rgs = {
    "rg-identity-prod-swe" = { loc = var.primary_location, env = "prod", owner = "grp-novahealth-security-team", bu = "Security", crit = "Critical", cc = "IT-003" }
    "rg-identity-dr-weu"   = { loc = var.dr_location,      env = "dr",   owner = "grp-novahealth-security-team", bu = "Security", crit = "Critical", cc = "IT-003" }
  }

    # =========================================================================
  # 3. SUSCRIPCIÓN: MANAGEMENT
  # =========================================================================
  management_rgs = {
    "rg-monitoring-prod-swe" = { loc = var.primary_location, env = "prod",    owner = "grp-novahealth-ops-team", bu = "FinOps",          crit = "High",   cc = "IT-004" }
    "rg-automation-prod-swe" = { loc = var.primary_location, env = "prod",    owner = "grp-novahealth-ops-team", bu = "FinOps",          crit = "High",   cc = "IT-004" }
    "rg-backup-prod-swe"     = { loc = var.primary_location, env = "prod",    owner = "grp-novahealth-ops-team", bu = "FinOps",          crit = "Critical",cc = "IT-004" }
    "rg-sandbox-swe"         = { loc = var.primary_location, env = "sandbox", owner = "grp-novahealth-dev-team", bu = "HospitalSystems", crit = "Low",    cc = "IT-009" }
    
    "rg-monitoring-dr-weu"   = { loc = var.dr_location,      env = "dr",      owner = "grp-novahealth-ops-team", bu = "FinOps",          crit = "High",   cc = "IT-004" }
    "rg-automation-dr-weu"   = { loc = var.dr_location,      env = "dr",      owner = "grp-novahealth-ops-team", bu = "FinOps",          crit = "High",   cc = "IT-004" }
    "rg-backup-dr-weu"       = { loc = var.dr_location,      env = "dr",      owner = "grp-novahealth-ops-team", bu = "FinOps",          crit = "Critical",cc = "IT-004" }
  }


    # =========================================================================
  # 4. SUSCRIPCIÓN: PRODUCTION
  # =========================================================================
  production_rgs = {
    "rg-network-aks-prod-swe"     = { loc = var.primary_location, env = "prod", owner = "grp-novahealth-network-team",     bu = "HospitalSystems", crit = "High", cc = "IT-005" }
    "rg-aks-prod-swe"             = { loc = var.primary_location, env = "prod", owner = "grp-novahealth-application-team", bu = "HospitalSystems", crit = "High", cc = "IT-005" }
    "rg-network-apps-prod-swe"    = { loc = var.primary_location, env = "prod", owner = "grp-novahealth-network-team",     bu = "HospitalSystems", crit = "High", cc = "IT-005" }
    "rg-apps-prod-swe"            = { loc = var.primary_location, env = "prod", owner = "grp-novahealth-application-team", bu = "HospitalSystems", crit = "High", cc = "IT-005" }
    "rg-shared-prod-swe"         = { loc = var.primary_location, env = "prod", owner = "grp-novahealth-it-core",          bu = "HospitalSystems", crit = "High", cc = "IT-005" }
    "rg-rag-prod-swe"            = { loc = var.primary_location, env = "prod", owner = "grp-novahealth-clinicalai-team", bu = "ClinicalAI", crit = "High",     cc = "IT-006" }
    
    "rg-network-dev-swe"         = { loc = var.primary_location, env = "dev",  owner = "grp-novahealth-network-team",    bu = "HospitalSystems", crit = "Low",    cc = "IT-007" }
    "rg-aks-dev-swe"             = { loc = var.primary_location, env = "dev",  owner = "grp-novahealth-dev-team",        bu = "HospitalSystems", crit = "Low",    cc = "IT-007" }
    "rg-apps-dev-swe"            = { loc = var.primary_location, env = "dev",  owner = "grp-novahealth-dev-team",        bu = "HospitalSystems", crit = "Low",    cc = "IT-007" }
    "rg-shared-services-dev-swe" = { loc = var.primary_location, env = "dev",  owner = "grp-novahealth-it-core",         bu = "HospitalSystems", crit = "Low",    cc = "IT-007" }
    
    "rg-network-qa-swe"          = { loc = var.primary_location, env = "qa",   owner = "grp-novahealth-network-team",    bu = "HospitalSystems", crit = "Medium", cc = "IT-008" }
    "rg-apps-qa-swe"             = { loc = var.primary_location, env = "qa",   owner = "grp-novahealth-qa-team",         bu = "HospitalSystems", crit = "Medium", cc = "IT-008" }
    "rg-shared-qa-swe"           = { loc = var.primary_location, env = "qa",   owner = "grp-novahealth-it-core",         bu = "HospitalSystems", crit = "Medium", cc = "IT-008" }

    "rg-network-aks-dr-weu"       = { loc = var.dr_location,      env = "dr",   owner = "grp-novahealth-network-team",     bu = "HospitalSystems", crit = "High", cc = "IT-005" }
    "rg-aks-dr-weu"               = { loc = var.dr_location,      env = "dr",   owner = "grp-novahealth-application-team", bu = "HospitalSystems", crit = "High", cc = "IT-005" }
    "rg-network-apps-dr-weu"      = { loc = var.dr_location,      env = "dr",   owner = "grp-novahealth-network-team",     bu = "HospitalSystems", crit = "High", cc = "IT-005" }
    "rg-apps-dr-weu"              = { loc = var.dr_location,      env = "dr",   owner = "grp-novahealth-application-team", bu = "HospitalSystems", crit = "High", cc = "IT-005" }
    "rg-shared-dr-weu"            = { loc = var.dr_location,      env = "dr",   owner = "grp-novahealth-it-core",          bu = "HospitalSystems", crit = "High", cc = "IT-005" }
    "rg-rag-dr-weu"               = { loc = var.dr_location,      env = "dr",   owner = "grp-novahealth-clinicalai-team", bu = "ClinicalAI", crit = "High",     cc = "IT-006" }
  }

  # =========================================================================
  # 5. SUSCRIPCIÓN: PLATFORM SERVICES (DATA & IA)
  # =========================================================================
  dataia_rgs = {
    "rg-network-shared-prod-swe"  = { loc = var.primary_location, env = "prod", owner = "grp-novahealth-network-team",     bu = "HospitalSystems", crit = "High", cc = "IT-005" }
    "rg-shared-services-prod-swe" = { loc = var.primary_location, env = "prod", owner = "grp-novahealth-it-core",          bu = "HospitalSystems", crit = "High", cc = "IT-005" }
    "rg-network-dataai-prod-swe"  = { loc = var.primary_location, env = "prod", owner = "grp-novahealth-network-team",    bu = "ClinicalAI", crit = "Critical", cc = "IT-006" }
    "rg-dataai-prod-swe"          = { loc = var.primary_location, env = "prod", owner = "grp-novahealth-clinicalai-team", bu = "ClinicalAI", crit = "Critical", cc = "IT-006" }
    
    "rg-dataai-dev-swe"          = { loc = var.primary_location, env = "dev",  owner = "grp-novahealth-clinicalai-team", bu = "ClinicalAI", crit = "Low",    cc = "IT-007" }
    "rg-dataai-qa-swe"            = { loc = var.primary_location, env = "qa",   owner = "grp-novahealth-clinicalai-team", bu = "ClinicalAI", crit = "Medium", cc = "IT-008" }

    "rg-network-shared-dr-weu"    = { loc = var.dr_location,      env = "dr",   owner = "grp-novahealth-network-team",     bu = "HospitalSystems", crit = "High", cc = "IT-005" }
    "rg-shared-services-dr-weu"   = { loc = var.dr_location,      env = "dr",   owner = "grp-novahealth-it-core",          bu = "HospitalSystems", crit = "High", cc = "IT-005" }
    "rg-network-dataai-dr-weu"    = { loc = var.dr_location,      env = "dr",   owner = "grp-novahealth-network-team",    bu = "ClinicalAI", crit = "Critical", cc = "IT-006" }
    "rg-dataai-dr-weu"            = { loc = var.dr_location,      env = "dr",   owner = "grp-novahealth-clinicalai-team", bu = "ClinicalAI", crit = "Critical", cc = "IT-006" }
  }
}

# =============================================================================
# DESPLIEGUE SOBRE LAS 5 SUSCRIPCIONES
# =============================================================================

resource "azurerm_resource_group" "connectivity" {
  provider = azurerm.connectivity
  for_each = { for k, v in local.connectivity_rgs : k => v if v.loc == local.selected_location }
  name     = each.key
  location = each.value.loc
  tags = {
    environment  = each.value.env
    owner        = each.value.owner
    cost-center  = each.value.cc
    project      = local.project_name
    businessUnit = each.value.bu
    criticality  = each.value.crit
    region       = each.value.loc == var.primary_location ? "SwedenCentral" : "WestEurope"
  }
}

resource "azurerm_resource_group" "identity" {
  provider = azurerm.identity
  for_each = { for k, v in local.identity_rgs : k => v if v.loc == local.selected_location }
  name     = each.key
  location = each.value.loc
  tags = {
    environment  = each.value.env
    owner        = each.value.owner
    cost-center  = each.value.cc
    project      = local.project_name
    businessUnit = each.value.bu
    criticality  = each.value.crit
    region       = each.value.loc == var.primary_location ? "SwedenCentral" : "WestEurope"
  }
}

resource "azurerm_resource_group" "management" {
  provider = azurerm.management
  for_each = { for k, v in local.management_rgs : k => v if v.loc == local.selected_location }
  name     = each.key
  location = each.value.loc
  tags = {
    environment  = each.value.env
    owner        = each.value.owner
    cost-center  = each.value.cc
    project      = local.project_name
    businessUnit = each.value.bu
    criticality  = each.value.crit
    region       = each.value.loc == var.primary_location ? "SwedenCentral" : "WestEurope"
  }
}

resource "azurerm_resource_group" "production" {
  provider = azurerm.production
  for_each = { for k, v in local.production_rgs : k => v if v.loc == local.selected_location }
  name     = each.key
  location = each.value.loc
  tags = {
    environment  = each.value.env
    owner        = each.value.owner
    cost-center  = each.value.cc
    project      = local.project_name
    businessUnit = each.value.bu
    criticality  = each.value.crit
    region       = each.value.loc == var.primary_location ? "SwedenCentral" : "WestEurope"
  }
}

resource "azurerm_resource_group" "data_ai" {
  provider = azurerm.data_ai
  for_each = { for k, v in local.dataia_rgs : k => v if v.loc == local.selected_location }
  name     = each.key
  location = each.value.loc
  tags = {
    environment  = each.value.env
    owner        = each.value.owner
    cost-center  = each.value.cc
    project      = local.project_name
    businessUnit = each.value.bu
    criticality  = each.value.crit
    region       = each.value.loc == var.primary_location ? "SwedenCentral" : "WestEurope"
  }
}