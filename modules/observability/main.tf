# Archivo: modules/observability/main.tf

# =========================================================================
# MÓDULO DE OBSERVABILIDAD Y MONITORIZACIÓN CENTRALIZADA (NOVAHEALTH)
# Ubicación: Suscripción MANAGEMENT (rg-monitoring-prod-swe)
# =========================================================================

locals {
  # RG de destino para observabilidad en la suscripción de Management
  monitoring_rg_name = lookup(var.resource_group_names, "rg-monitoring-prod-swe", "rg-monitoring-prod-swe")

  # Mapeo de región para sufijo si var.location varía
  region_suffix = lower(var.location) == "swedencentral" ? "swe" : (lower(var.location) == "westeurope" ? "weu" : "swe")
  region_name   = lower(var.location) == "swedencentral" ? "SwedenCentral" : "WestEurope"

  # -------------------------------------------------------------------------
  # 1. TAGS OPERACIONALES (CC-004: Management)
  # -------------------------------------------------------------------------
  management_tags = merge(
    var.tags,
    {
      environmentType = lower(var.location) == "swedencentral" ? "primary" : "dr"
      environment     = "prod"
      region          = local.region_name
      owner           = "grp-novahealth-ops-team"
      costCenter      = "CC-004"
      project         = "NovaHealth-LandingZone"
      workload        = "platformshared-services"
      criticality     = "High"
    }
  )

  # -------------------------------------------------------------------------
  # 2. TAGS SEGURIDAD / SIEM (CC-003: Security)
  # -------------------------------------------------------------------------
  sentinel_tags = merge(
    var.tags,
    {
      environmentType = lower(var.location) == "swedencentral" ? "primary" : "dr"
      environment     = "prod"
      region          = local.region_name
      owner           = "grp-novahealth-security-team"
      costCenter      = "CC-003"
      project         = "NovaHealth-LandingZone"
      workload        = "security-compliance"
      criticality     = "Critical"
    }
  )
}

# -------------------------------------------------------------------------
# 1. LOG ANALYTICS WORKSPACE CENTRALIZADO — CC-004 (Management)
# -------------------------------------------------------------------------
resource "azurerm_log_analytics_workspace" "central" {
  name                = "la-monitoring-prod-${local.region_suffix}"
  location            = var.location
  resource_group_name = local.monitoring_rg_name
  sku                 = "PerGB2018"
  retention_in_days   = var.log_analytics_retention_in_days
  tags                = merge(local.management_tags, { criticality = "Critical" })
}

# -------------------------------------------------------------------------
# 2. APPLICATION INSIGHTS (WORKSPACE-BASED) — CC-004 (Management)
# -------------------------------------------------------------------------
resource "azurerm_application_insights" "app_insights" {
  name                = "appi-monitoring-prod-${local.region_suffix}-001"
  location            = var.location
  resource_group_name = local.monitoring_rg_name
  workspace_id        = azurerm_log_analytics_workspace.central.id
  application_type    = "web"
  tags                = local.management_tags
}

# -------------------------------------------------------------------------
# 3. MICROSOFT SENTINEL (SECURITY INSIGHTS SOLUTION) — CC-003 (Security)
# -------------------------------------------------------------------------
resource "azurerm_log_analytics_solution" "sentinel" {
  solution_name         = "SecurityInsights"
  location              = var.location
  resource_group_name   = local.monitoring_rg_name
  workspace_resource_id = azurerm_log_analytics_workspace.central.id
  workspace_name        = azurerm_log_analytics_workspace.central.name

  plan {
    publisher = "Microsoft"
    product   = "OMSGallery/SecurityInsights"
  }

  tags = local.sentinel_tags
}

# -------------------------------------------------------------------------
# 4. MONITOR ACTION GROUP — CC-004 (Management)
# -------------------------------------------------------------------------
resource "azurerm_monitor_action_group" "ops_alerts" {
  name                = "ag-monitoring-prod-${local.region_suffix}"
  resource_group_name = local.monitoring_rg_name
  short_name          = "ag-ops-alert"
  tags                = local.management_tags

  email_receiver {
    name                    = "NovaHealth-Ops-Team"
    email_address           = var.notification_email
    use_common_alert_schema = true
  }
}