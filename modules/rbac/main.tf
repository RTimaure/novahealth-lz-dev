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

# -------------------------------------------------------------------------
# 1. CREACIÓN DE GRUPOS EN MICROSOFT ENTRA ID (RBAC COMPLIANCE)
# -------------------------------------------------------------------------

locals {
  entra_groups = {
    "grp-novahealth-platform-admins" = "Administradores de la plataforma Landing Zone Owner"
    "grp-novahealth-security-team"   = "Equipo de Seguridad Security Admin"
    "grp-novahealth-governance-team" = "Equipo de Gobierno y Políticas Cloud Governance Team"
    "grp-novahealth-finops-team"     = "Equipo FinOps control de costes"
    "grp-novahealth-ops-team"        = "Equipo Operaciones Producción"
    "grp-novahealth-dev-team"        = "Equipo Desarrollo Dev/QA"
    "grp-novahealth-clinicalai-team" = "Equipo Inteligencia Artificial Clínica"
    "grp-novahealth-network-team"    = "Equipo Conectividad y Redes"
    "grp-novahealth-data-team"       = "Equipo Gestión de Datos Sanitarios"
    "grp-novahealth-auditors"        = "Auditoría regulatoria GDPR y NIS2"
  }
}

resource "azuread_group" "novahealth_groups" {
  for_each         = local.entra_groups
  display_name     = each.key
  description      = each.value
  security_enabled = true
}

# -------------------------------------------------------------------------
# 2. NORMALIZACIÓN DE SCOPES PARA ROLES CUSTOM Y ASIGNACIONES
# -------------------------------------------------------------------------

locals {
  # Extraemos las suscripciones únicas de entrada y les aseguramos el formato URI formal
  normalized_sub_scopes = distinct([
    for sub_id in values(var.target_subscriptions) :
    startswith(sub_id, "/subscriptions/") ? sub_id : "/subscriptions/${sub_id}"
    if sub_id != ""
  ])

  # Combinamos el MG raíz y las suscripciones para que Azure autorice la asignación en ambos niveles
  all_assignable_scopes = concat([var.root_mg_id], local.normalized_sub_scopes)
}

# -------------------------------------------------------------------------
# 3. DEFINICIÓN DE ROLES CUSTOM EN AZURE (SEPARANDO DATA ACTIONS)
# -------------------------------------------------------------------------

resource "azurerm_role_definition" "custom_roles" {
  for_each = {
    "NovaHealth-ClinicalData-Reader" = {
      description  = "Lectura de Storage Accounts con datos clínicos"
      actions      = []
      data_actions = ["Microsoft.Storage/storageAccounts/blobServices/containers/blobs/read"]
    }
    "NovaHealth-ClinicalData-Operator" = {
      description  = "Lectura y escritura en RGs de datos clínicos"
      actions      = []
      data_actions = [
        "Microsoft.Storage/storageAccounts/blobServices/containers/blobs/read",
        "Microsoft.Storage/storageAccounts/blobServices/containers/blobs/write",
        "Microsoft.Storage/storageAccounts/blobServices/containers/blobs/delete"
      ]
    }
    "NovaHealth-Compliance-Auditor" = {
      description = "Lectura de logs, políticas y Defender para auditoría regulatoria"
      actions = [
        "Microsoft.Authorization/policyAssignments/read",
        "Microsoft.Authorization/policyDefinitions/read",
        "Microsoft.Security/policies/read",
        "Microsoft.OperationalInsights/workspaces/read"
      ]
      data_actions = []
    }
    "NovaHealth-FinOps-Viewer" = {
      description = "Lectura de Cost Management y tags por suscripción"
      actions = [
        "Microsoft.Consumption/usageDetails/read",
        "Microsoft.CostManagement/query/read",
        "Microsoft.Resources/subscriptions/tagNames/read"
      ]
      data_actions = []
    }
  }

  name        = each.key
  scope       = var.root_mg_id
  description = each.value.description

  permissions {
    actions          = each.value.actions
    data_actions     = each.value.data_actions
    not_actions      = []
    not_data_actions = []
  }

  # Inyectamos todos los ámbitos autorizados para que ARM no bloquee la asignación
  assignable_scopes = local.all_assignable_scopes
}

# -------------------------------------------------------------------------
# 4. ASIGNACIONES DE ROLES (USANDO ROLE DEFINITION ID EXACTO)
# -------------------------------------------------------------------------

locals {
  mg_assignments = {
    "root_platform_admins" = {
      scope        = var.root_mg_id
      role_name    = "Owner"
      principal_id = azuread_group.novahealth_groups["grp-novahealth-platform-admins"].object_id
    }
    "security_admin" = {
      scope        = var.security_mg_id
      role_name    = "Security Admin"
      principal_id = azuread_group.novahealth_groups["grp-novahealth-security-team"].object_id
    }
    "root_governance" = {
      scope        = var.root_mg_id
      role_name    = "Resource Policy Contributor"
      principal_id = azuread_group.novahealth_groups["grp-novahealth-governance-team"].object_id
    }
    "root_auditors" = {
      scope        = var.root_mg_id
      role_name    = "Reader"
      principal_id = azuread_group.novahealth_groups["grp-novahealth-auditors"].object_id
    }
  }

  dedup_sub_assignments = {
    for sub_scope in local.normalized_sub_scopes :
    "finops_${md5(sub_scope)}" => {
      scope        = sub_scope
      principal_id = azuread_group.novahealth_groups["grp-novahealth-finops-team"].object_id
    }
  }
}

# Asignaciones a nivel de Management Group (Roles Built-in usando su nombre)
resource "azurerm_role_assignment" "mg_rbac" {
  for_each             = local.mg_assignments
  scope                = each.value.scope
  role_definition_name = each.value.role_name
  principal_id         = each.value.principal_id
  depends_on           = [azurerm_role_definition.custom_roles]
}

# Asignaciones a nivel de Suscripción (Roles Custom usando role_definition_id exacto)
resource "azurerm_role_assignment" "sub_rbac" {
  for_each           = local.dedup_sub_assignments
  scope              = each.value.scope
  role_definition_id = azurerm_role_definition.custom_roles["NovaHealth-FinOps-Viewer"].role_definition_resource_id
  principal_id       = each.value.principal_id
  depends_on         = [azurerm_role_definition.custom_roles]
}