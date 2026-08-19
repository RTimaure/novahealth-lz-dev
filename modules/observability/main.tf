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

  # 7 Tags obligatorios de NovaHealth (Gobernanza)
  observability_tags = merge(
    var.tags,
    {
      environment  = lookup(var.tags, "environment", "prod")
      owner        = "grp-novahealth-ops-team"
      cost-center  = "IT-004"
      project      = "NovaHealth-LandingZone"
      businessUnit = "FinOps"
      criticality  = "High"
      region       = lower(var.location) == "swedencentral" ? "SwedenCentral" : "WestEurope"
    }
  )
}

# -------------------------------------------------------------------------
# 1. LOG ANALYTICS WORKSPACE CENTRALIZADO
# Naming Cluster C1 (4 segmentos): [prefix]-[purpose]-[env]-[region]
# Ejemplo: log-monitoring-prod-swe
# -------------------------------------------------------------------------
resource "azurerm_log_analytics_workspace" "central" {
  name                = "log-monitoring-prod-${local.region_suffix}"
  location            = var.location
  resource_group_name = local.monitoring_rg_name
  sku                 = "PerGB2018"
  retention_in_days   = var.log_analytics_retention_in_days
  tags                = local.observability_tags
}

# -------------------------------------------------------------------------
# 2. APPLICATION INSIGHTS (WORKSPACE-BASED)
# Naming Cluster C2 (5 segmentos): [prefix]-[purpose]-[env]-[region]-[idx]
# Ejemplo: appi-monitoring-prod-swe-001
# -------------------------------------------------------------------------
resource "azurerm_application_insights" "app_insights" {
  name                = "appi-monitoring-prod-${local.region_suffix}-001"
  location            = var.location
  resource_group_name = local.monitoring_rg_name
  workspace_id        = azurerm_log_analytics_workspace.central.id
  application_type    = "web"
  tags                = local.observability_tags
}

# -------------------------------------------------------------------------
# 3. MICROSOFT SENTINEL (SECURITY INSIGHTS SOLUTION)
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

  tags = local.observability_tags
}

# -------------------------------------------------------------------------
# 4. MONITOR ACTION GROUP (NOTIFICACIONES OPERACIONALES Y SRE)
# Naming Cluster C1 (4 segmentos): [prefix]-[purpose]-[env]-[region]
# Ejemplo: ag-monitoring-prod-swe
# -------------------------------------------------------------------------
resource "azurerm_monitor_action_group" "ops_alerts" {
  name                = "ag-monitoring-prod-${local.region_suffix}"
  resource_group_name = local.monitoring_rg_name
  short_name          = "ag-ops-alert"
  tags                = local.observability_tags

  email_receiver {
    name                    = "NovaHealth-Ops-Team"
    email_address           = var.notification_email
    use_common_alert_schema = true
  }
}
