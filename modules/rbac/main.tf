# Archivo: modules/rbac/main.tf

terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
    azuread = {
      source  = "hashicorp/azuread"
      version = "~> 2.0"
    }
  }
}

# =========================================================================
# 1. CREACIÓN DE GRUPOS CORPORATIVOS EN MICROSOFT ENTRA ID
# =========================================================================
resource "azuread_group" "novahealth_groups" {
  for_each = toset([
    "grp-novahealth-security-team",
    "grp-novahealth-governance-team",
    "grp-novahealth-finops-team",
    "grp-novahealth-auditors",
    "grp-novahealth-ops-team",
    "grp-novahealth-dev-team",
    "grp-novahealth-sre-team",
    "grp-novahealth-clinical-ai-team",
    "grp-novahealth-qa-team",
    "grp-novahealth-dev-lead",
    "grp-novahealth-application-team",
    "grp-novahealth-data-team",
    "grp-novahealth-network-team"
  ])

  display_name     = each.key
  security_enabled = true
}

# =========================================================================
# 2. DEFINICIÓN DE ROLES CUSTOM CORPORATIVOS (SECTOR SALUD - NOVAHEALTH)
# =========================================================================
locals {
  normalized_sub_scopes = [
    for sub_id in values(var.target_subscriptions) :
    startswith(sub_id, "/subscriptions/") ? sub_id : "/subscriptions/${sub_id}"
  ]
  all_assignable_scopes = concat([var.root_mg_id], local.normalized_sub_scopes)
}

resource "azurerm_role_definition" "custom_roles" {
  for_each = {
    "NovaHealth-ClinicalData-Reader" = {
      description  = "Lectura de Storage Accounts con datos clínicos y controlados."
      actions      = ["Microsoft.Storage/storageAccounts/read", "Microsoft.Storage/storageAccounts/blobServices/containers/read"]
      data_actions = ["Microsoft.Storage/storageAccounts/blobServices/containers/blobs/read"]
    }
    "NovaHealth-ClinicalData-Operator" = {
      description  = "Lectura y escritura en RGs de datos clínicos para aplicaciones."
      actions      = ["Microsoft.Storage/storageAccounts/read", "Microsoft.Storage/storageAccounts/blobServices/containers/*"]
      data_actions = ["Microsoft.Storage/storageAccounts/blobServices/containers/blobs/read", "Microsoft.Storage/storageAccounts/blobServices/containers/blobs/write"]
    }
    "NovaHealth-Compliance-Auditor" = {
      description = "Lectura de logs, políticas y Defender para auditoría GDPR/NIS2."
      actions = [
        "Microsoft.Authorization/policyAssignments/read",
        "Microsoft.Authorization/policyDefinitions/read",
        "Microsoft.Security/assessments/read",
        "Microsoft.Insights/alertRules/read",
        "Microsoft.OperationalInsights/workspaces/read"
      ]
      data_actions = []
    }
    # Corrección de la acción obsoleta de Consumption a CostManagement y validas
    "NovaHealth-FinOps-Viewer" = {
      description = "Lectura de Cost Management y etiquetas para seguimiento financiero."
      actions = [
        "Microsoft.CostManagement/budgets/read",
        "Microsoft.CostManagement/query/read",
        "Microsoft.Consumption/usageDetails/read",
        "Microsoft.Resources/subscriptions/resourceGroups/read",
        "Microsoft.Resources/subscriptions/read"
      ]
      data_actions = []
    }
  }

  name              = each.key
  scope             = var.root_mg_id
  description       = each.value.description
  assignable_scopes = local.all_assignable_scopes

  permissions {
    actions      = each.value.actions
    data_actions = each.value.data_actions
  }
}

# =========================================================================
# 3. ASIGNACIONES DE ROLES A NIVEL DE MANAGEMENT GROUP (NIVEL 1)
# =========================================================================
locals {
  platform_mg_id = replace(var.root_mg_id, "nh-root", "nh-platform")

  mg_assignments = {
    "security_admin" = {
      scope        = var.security_mg_id
      role_name    = "Security Admin"
      principal_id = azuread_group.novahealth_groups["grp-novahealth-security-team"].object_id
    }
    "platform_governance" = {
      scope        = local.platform_mg_id
      role_name    = "Resource Policy Contributor"
      principal_id = azuread_group.novahealth_groups["grp-novahealth-governance-team"].object_id
    }
    "root_auditors" = {
      scope        = var.root_mg_id
      role_name    = "Reader"
      principal_id = azuread_group.novahealth_groups["grp-novahealth-auditors"].object_id
    }
    "root_finops" = {
      scope              = var.root_mg_id
      role_definition_id = azurerm_role_definition.custom_roles["NovaHealth-FinOps-Viewer"].role_definition_resource_id
      principal_id       = azuread_group.novahealth_groups["grp-novahealth-finops-team"].object_id
    }
  }
}

resource "azurerm_role_assignment" "mg_rbac" {
  for_each = local.mg_assignments

  scope                = each.value.scope
  role_definition_name = lookup(each.value, "role_name", null)
  role_definition_id   = lookup(each.value, "role_definition_id", null)
  principal_id         = each.value.principal_id
}

# =========================================================================
# 4. ASIGNACIONES A NIVEL DE SUSCRIPCIÓN (NIVEL 2)
# =========================================================================
locals {
  sub_assignments_raw = flatten([
    contains(keys(var.target_subscriptions), "production") ? [
      { key = "prod_ops", sub = var.target_subscriptions["production"], role = "Contributor", group = "grp-novahealth-ops-team" },
      { key = "prod_dev", sub = var.target_subscriptions["production"], role = "Reader", group = "grp-novahealth-dev-team" },
      { key = "prod_sre", sub = var.target_subscriptions["production"], role = "Monitoring Contributor", group = "grp-novahealth-sre-team" }
    ] : [],

    contains(keys(var.target_subscriptions), "platform_services") ? [
      { key = "platform_services_clinical", sub = var.target_subscriptions["platform_services"], role = "Contributor", group = "grp-novahealth-clinical-ai-team" }
    ] : [],

    contains(keys(var.target_subscriptions), "qa") ? [
      { key = "qa_qa", sub = var.target_subscriptions["qa"], role = "Contributor", group = "grp-novahealth-qa-team" },
      { key = "qa_dev", sub = var.target_subscriptions["qa"], role = "Reader", group = "grp-novahealth-dev-team" }
    ] : [],

    contains(keys(var.target_subscriptions), "development") ? [
      { key = "dev_dev", sub = var.target_subscriptions["development"], role = "Contributor", group = "grp-novahealth-dev-team" },
      { key = "dev_lead", sub = var.target_subscriptions["development"], role = "Cost Management Contributor", group = "grp-novahealth-dev-lead" }
    ] : []
  ])

  dedup_sub_assignments = { for item in local.sub_assignments_raw : item.key => item }
}

resource "azurerm_role_assignment" "sub_rbac" {
  for_each = local.dedup_sub_assignments

  scope                = startswith(each.value.sub, "/subscriptions/") ? each.value.sub : "/subscriptions/${each.value.sub}"
  role_definition_name = each.value.role
  principal_id         = azuread_group.novahealth_groups[each.value.group].object_id

  depends_on = [azurerm_role_definition.custom_roles]
}

# =========================================================================
# 5. ASIGNACIÓN SERVICE PRINCIPAL CI/CD (TERRAFORM AUTOMATION)
# =========================================================================
resource "azurerm_role_assignment" "cicd_rbac" {
  for_each = var.cicd_service_principal_object_id != "" ? var.target_subscriptions : {}

  scope                = startswith(each.value, "/subscriptions/") ? each.value : "/subscriptions/${each.value}"
  role_definition_name = "Contributor"
  principal_id         = var.cicd_service_principal_object_id
}