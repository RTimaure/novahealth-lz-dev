# Archivo: modules/observability/diagnostic_settings.tf

# =========================================================================
# DIAGNOSTIC SETTINGS PARA RECURSOS CENTRALES DE NETWORKING Y SEGURIDAD
# Transmite métricas y logs al Log Analytics centralizado (NovaHealth)
# =========================================================================

variable "diagnostic_target_resources" {
  description = "Mapa de IDs de recursos para aplicar Diagnostic Settings hacia Log Analytics"
  type = object({
    firewall_id            = optional(string)
    application_gateway_id = optional(string)
    vpn_gateway_id         = optional(string)
    bastion_id             = optional(string)
    dns_resolver_id        = optional(string)
    key_vault_ids          = optional(list(string), [])
  })
  default = {}
}

# 1. Azure Firewall Diagnostics
resource "azurerm_monitor_diagnostic_setting" "firewall" {
 # count                      = var.diagnostic_target_resources.firewall_id != null ? 1 : 0
  count = var.enabled_features.firewall ? 1 : 0
  name                       = "diag-afw-prod-${local.region_suffix}"
  target_resource_id         = var.diagnostic_target_resources.firewall_id
  log_analytics_workspace_id = azurerm_log_analytics_workspace.central.id

  enabled_log {
    category_group = "allLogs"
  }

  metric {
    category = "AllMetrics"
    enabled  = true
  }
}

# 2. Application Gateway (WAF) Diagnostics
resource "azurerm_monitor_diagnostic_setting" "appgw" {
  #count                      = var.diagnostic_target_resources.application_gateway_id != null ? 1 : 0
  count = var.enabled_features.application_gateway ? 1 : 0
  name                       = "diag-agw-prod-${local.region_suffix}"
  target_resource_id         = var.diagnostic_target_resources.application_gateway_id
  log_analytics_workspace_id = azurerm_log_analytics_workspace.central.id

  enabled_log {
    category_group = "allLogs"
  }

  metric {
    category = "AllMetrics"
    enabled  = true
  }
}

# 3. VPN Gateway Diagnostics
resource "azurerm_monitor_diagnostic_setting" "vpngw" {
  #count                      = var.diagnostic_target_resources.vpn_gateway_id != null ? 1 : 0
  count = var.enabled_features.vpn_gateway ? 1 : 0
  name                       = "diag-vpngw-prod-${local.region_suffix}"
  target_resource_id         = var.diagnostic_target_resources.vpn_gateway_id
  log_analytics_workspace_id = azurerm_log_analytics_workspace.central.id

  enabled_log {
    category_group = "allLogs"
  }

  metric {
    category = "AllMetrics"
    enabled  = true
  }
}

# 4. Azure Bastion Diagnostics
resource "azurerm_monitor_diagnostic_setting" "bastion" {
  #count                      = var.diagnostic_target_resources.bastion_id != null ? 1 : 0
  count = var.enabled_features.bastion ? 1 : 0
  name                       = "diag-bastion-prod-${local.region_suffix}"
  target_resource_id         = var.diagnostic_target_resources.bastion_id
  log_analytics_workspace_id = azurerm_log_analytics_workspace.central.id

  enabled_log {
    category_group = "allLogs"
  }

  metric {
    category = "AllMetrics"
    enabled  = true
  }
}

# 5. Private DNS Resolver Diagnostics
resource "azurerm_monitor_diagnostic_setting" "dns_resolver" {
  #count                      = var.diagnostic_target_resources.dns_resolver_id != null ? 1 : 0
  count = var.enabled_features.dns_resolver ? 1 : 0
  name                       = "diag-dnspr-prod-${local.region_suffix}"
  target_resource_id         = var.diagnostic_target_resources.dns_resolver_id
  log_analytics_workspace_id = azurerm_log_analytics_workspace.central.id

  metric {
    category = "AllMetrics"
    enabled  = true
  }
}
