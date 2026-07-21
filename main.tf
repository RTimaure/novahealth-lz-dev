# Archivo: main.tf

# -------------------------------------------------------------------------
# 1. EMBUDO DE DESACOPLAMIENTO DE SUSCRIPCIONES (ESTUDIANTE VS ENTERPRISE)
# -------------------------------------------------------------------------
locals {
  target_subscriptions = var.use_enterprise_subscriptions ? module.subscriptions.subscription_ids : {
    production   = var.student_subscription_id
    identity     = var.student_subscription_id
    connectivity = var.student_subscription_id
    data_ai      = var.student_subscription_id
    sandbox      = var.student_subscription_id
  }
}

# -------------------------------------------------------------------------
# 2. CAPA 1: MANAGEMENT GROUPS (JERARQUÍA NOVAHEALTH)
# -------------------------------------------------------------------------
module "management_groups" {
  source = "./modules/management_groups"
}

# -------------------------------------------------------------------------
# 3. CAPA 2: SUSCRIPCIONES (SOPORTE DUAL ESTUDIANTE Y ENTERPRISE)
# -------------------------------------------------------------------------
module "subscriptions" {
  source                       = "./modules/subscriptions"
  use_enterprise_subscriptions = var.use_enterprise_subscriptions
  student_subscription_id      = var.student_subscription_id
  enterprise_subscriptions     = var.enterprise_subscriptions
  management_group_ids         = module.management_groups.management_group_ids
  subscription_to_mg           = var.subscription_to_mg
}

# -------------------------------------------------------------------------
# 4. CAPA 3: AZURE POLICY (GOBIERNO E INICIATIVAS)
# -------------------------------------------------------------------------
module "policy" {
  source               = "./modules/policy"
  root_mg_id           = lookup(module.management_groups.management_group_ids, "root", lookup(module.management_groups.management_group_ids, "nh-root", ""))
  landing_zones_mg_id  = lookup(module.management_groups.management_group_ids, "landing_zones", lookup(module.management_groups.management_group_ids, "nh-landing-zones", ""))
  platform_mg_id       = lookup(module.management_groups.management_group_ids, "platform", lookup(module.management_groups.management_group_ids, "nh-platform", ""))
  target_subscriptions = local.target_subscriptions
}

# -------------------------------------------------------------------------
# 5. CAPA 4: RBAC Y ZERO TRUST
# -------------------------------------------------------------------------
module "rbac" {
  source                           = "./modules/rbac"
  root_mg_id                       = lookup(module.management_groups.management_group_ids, "root", lookup(module.management_groups.management_group_ids, "nh-root", ""))
  security_mg_id                   = lookup(module.management_groups.management_group_ids, "security", lookup(module.management_groups.management_group_ids, "nh-security", ""))
  target_subscriptions             = local.target_subscriptions
  cicd_service_principal_object_id = var.cicd_service_principal_object_id
}

# -------------------------------------------------------------------------
# 6. CAPA 5: FINOPS Y CONTROL PRESUPUESTARIO
# -------------------------------------------------------------------------
module "finops" {
  source               = "./modules/finops"
  target_subscriptions = local.target_subscriptions
}



# -------------------------------------------------------------------------
# 7. CAPA 6: NETWORKING (TOPOLOGÍA HUB-AND-SPOKE NOVAHEALTH)
# -------------------------------------------------------------------------
module "networking" {
  source               = "./modules/networking"
  target_subscriptions = local.target_subscriptions

  # Inyección de las etiquetas obligatorias según política 'LZ-Tagging'
  tags = {
    Environment  = "Prod"
    BusinessUnit = "HospitalSystems"
    CostCenter   = "IT-001"
    Criticality  = "High"
    #Region       = "francecentral"
    Region       = "swedencentral"
  }
}