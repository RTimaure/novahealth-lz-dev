# Archivo: main.tf

# =========================================================================
# EMBUDO DE DESACOPLAMIENTO DE SUSCRIPCIONES (5 SUSCRIPCIONES MODO DEMO)
# =========================================================================
locals {
  target_subscriptions = module.subscriptions.subscription_ids

  root_mg_id     = lookup(module.management_groups.management_group_ids, "root", "nh-root")
  security_mg_id = lookup(module.management_groups.management_group_ids, "security", "nh-security")
}

# =========================================================================
# CAPA 1: JERARQUÍA DE MANAGEMENT GROUPS
# =========================================================================
module "management_groups" {
  source = "./modules/management_groups"
}

# =========================================================================
# CAPA 2: ASOCIACIÓN DE SUSCRIPCIONES BYOS
# =========================================================================
module "subscriptions" {
  source = "./modules/subscriptions"

  management_group_ids         = module.management_groups.management_group_ids
  use_enterprise_subscriptions = var.use_enterprise_subscriptions
  enterprise_subscriptions     = var.enterprise_subscriptions
  subscription_to_mg           = var.subscription_to_mg
  student_subscription_id      = var.student_subscription_id

  depends_on = [module.management_groups]
}

# =========================================================================
# CAPA 3: MÓDULO CENTRALIZADO DE RESOURCE GROUPS (5 PROVEEDORES FÍSICOS)
# =========================================================================
module "resource_groups" {
  source = "./modules/resource_groups"

  primary_location = var.primary_location
  dr_location      = var.dr_location
  deployment_scope = var.deployment_scope

  providers = {
    azurerm.connectivity = azurerm.connectivity
    azurerm.identity     = azurerm.identity
    azurerm.management   = azurerm.management
    azurerm.production   = azurerm.production
    azurerm.data_ai      = azurerm.data_ai
  }

  depends_on = [module.subscriptions]
}

# =========================================================================
# CAPA 4: GOBERNANZA DE POLÍTICAS (AZURE POLICY)
# =========================================================================
module "policy" {
  source = "./modules/policy"

  root_mg_id           = local.root_mg_id
  platform_mg_id       = lookup(module.management_groups.management_group_ids, "platform", "nh-platform")
  landing_zones_mg_id  = lookup(module.management_groups.management_group_ids, "landing_zones", "nh-landing-zones")
  management_group_ids = module.management_groups.management_group_ids
  target_subscriptions = local.target_subscriptions
  allowed_locations    = [var.location]

  depends_on = [module.management_groups]
}

# =========================================================================
# CAPA 5: CONTROL DE ACCESO (RBAC)
# =========================================================================
module "rbac" {
  source = "./modules/rbac"

  root_mg_id                       = local.root_mg_id
  security_mg_id                   = local.security_mg_id
  target_subscriptions             = local.target_subscriptions
  cicd_service_principal_object_id = var.cicd_service_principal_object_id

  depends_on = [module.policy]
}

# =========================================================================
# CAPA 6: INFRAESTRUCTURA DE RED (NETWORKING)
# =========================================================================
module "networking" {
  source               = "./modules/networking"
  location             = var.location
  target_subscriptions = local.target_subscriptions
  resource_group_names = module.resource_groups.rg_names

  tags = merge(
    var.tags,
    {
      environment  = "prod"
      project      = "NovaHealth-LandingZone"
      region       = var.location == "swedencentral" ? "SwedenCentral" : "WestEurope"
      cost-center  = "IT-001"
      businessUnit = "HospitalSystems"
      criticality  = "Critical"
      owner        = "grp-novahealth-network-team"
    }
  )

  providers = {
    azurerm.connectivity = azurerm.connectivity
    azurerm.identity     = azurerm.identity
    azurerm.management   = azurerm.management
    azurerm.production   = azurerm.production
    azurerm.data_ai      = azurerm.data_ai
  
  }

  depends_on = [module.resource_groups]
}

# =========================================================================
# CAPA 7: CONTROL FINANCIERO (FINOPS)
# =========================================================================
module "finops" {
  source = "./modules/finops"

  target_subscriptions = local.target_subscriptions
  notification_emails   = ["finops@novahealth.com"]

  depends_on = [module.networking]
}