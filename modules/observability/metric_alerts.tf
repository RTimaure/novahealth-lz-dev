# Archivo: modules/observability/metric_alerts.tf

# =========================================================================
# MONITOR METRIC ALERTS (SEGÚN DOCUMENTO DE MÉTRICAS Y ALARMAS V4)
# Convención C1: [alert]-[servicio]-[entorno]-[región]
# =========================================================================

# -------------------------------------------------------------------------
# 1. ALERTAS DE AZURE FIREWALL
# -------------------------------------------------------------------------
# A. Throughput / Utilización de Ancho de Banda > 80% (Capacidad)
resource "azurerm_monitor_metric_alert" "firewall_throughput" {
  #count               = var.diagnostic_target_resources.firewall_id != null ? 1 : 0
  count               = var.enabled_features.firewall ? 1 : 0
  name                = "alert-afw-throughput-prod-${local.region_suffix}"
  resource_group_name = local.monitoring_rg_name
  scopes              = [var.diagnostic_target_resources.firewall_id]
  description         = "Alerta si el Throughput de Azure Firewall supera el umbral crítico"
  severity            = 2
  frequency           = "PT5M"
  window_size         = "PT5M"
  tags                = local.observability_tags

  criteria {
    metric_namespace = "Microsoft.Network/azureFirewalls"
    metric_name      = "Throughput"
    aggregation      = "Average"
    operator         = "GreaterThan"
    threshold        = 800000000 # 800 Mbps
  }

  action {
    action_group_id = azurerm_monitor_action_group.ops_alerts.id
  }
}

# B. Agotamiento de puertos SNAT (SNAT Port Utilization > 80%)
resource "azurerm_monitor_metric_alert" "firewall_snat" {
  #count               = var.diagnostic_target_resources.firewall_id != null ? 1 : 0
  count               = var.enabled_features.firewall ? 1 : 0
  name                = "alert-afw-snat-prod-${local.region_suffix}"
  resource_group_name = local.monitoring_rg_name
  scopes              = [var.diagnostic_target_resources.firewall_id]
  description         = "Alerta si la utilización de puertos SNAT supera el 80%"
  severity            = 1
  frequency           = "PT1M"
  window_size         = "PT5M"
  tags                = local.observability_tags

  criteria {
    metric_namespace = "Microsoft.Network/azureFirewalls"
    metric_name      = "SNATPortUtilization"
    aggregation      = "Average"
    operator         = "GreaterThan"
    threshold        = 80
  }

  action {
    action_group_id = azurerm_monitor_action_group.ops_alerts.id
  }
}

# -------------------------------------------------------------------------
# 2. ALERTAS DE APPLICATION GATEWAY (WAF)
# -------------------------------------------------------------------------
# A. Peticiones Fallidas (Failed Requests / 5xx > 10)
resource "azurerm_monitor_metric_alert" "appgw_failed_requests" {
  #count               = var.diagnostic_target_resources.application_gateway_id != null ? 1 : 0
  count               = var.enabled_features.application_gateway ? 1 : 0
  name                = "alert-agw-failedreq-prod-${local.region_suffix}"
  resource_group_name = local.monitoring_rg_name
  scopes              = [var.diagnostic_target_resources.application_gateway_id]
  description         = "Alerta si el número de peticiones fallidas (5xx) supera el umbral"
  severity            = 1
  frequency           = "PT1M"
  window_size         = "PT5M"
  tags                = local.observability_tags

  criteria {
    metric_namespace = "Microsoft.Network/applicationGateways"
    metric_name      = "FailedRequests"
    aggregation      = "Total"
    operator         = "GreaterThan"
    threshold        = 10
  }

  action {
    action_group_id = azurerm_monitor_action_group.ops_alerts.id
  }
}

# B. Latencia de Respuesta (Total Time > 3 segundos)
resource "azurerm_monitor_metric_alert" "appgw_latency" {
  #count               = var.diagnostic_target_resources.application_gateway_id != null ? 1 : 0
  count               = var.enabled_features.application_gateway ? 1 : 0
  name                = "alert-agw-latency-prod-${local.region_suffix}"
  resource_group_name = local.monitoring_rg_name
  scopes              = [var.diagnostic_target_resources.application_gateway_id]
  description         = "Alerta si la latencia promedio del Application Gateway supera 3 segundos"
  severity            = 2
  frequency           = "PT5M"
  window_size         = "PT5M"
  tags                = local.observability_tags

  criteria {
    metric_namespace = "Microsoft.Network/applicationGateways"
    metric_name      = "ApplicationGatewayTotalTime"
    aggregation      = "Average"
    operator         = "GreaterThan"
    threshold        = 3
  }

  action {
    action_group_id = azurerm_monitor_action_group.ops_alerts.id
  }
}

# -------------------------------------------------------------------------
# 3. ALERTAS DE VPN GATEWAY (CONECTIVIDAD HÍBRIDA)
# -------------------------------------------------------------------------
# A. Ancho de banda de túnel saturado (Bandwidth > 80%)
resource "azurerm_monitor_metric_alert" "vpngw_bandwidth" {
  #count               = var.diagnostic_target_resources.vpn_gateway_id != null ? 1 : 0
  count               = var.enabled_features.vpn_gateway ? 1 : 0
  name                = "alert-vpngw-bandwidth-prod-${local.region_suffix}"
  resource_group_name = local.monitoring_rg_name
  scopes              = [var.diagnostic_target_resources.vpn_gateway_id]
  description         = "Alerta si el ancho de banda del VPN Gateway supera el 80%"
  severity            = 2
  frequency           = "PT5M"
  window_size         = "PT5M"
  tags                = local.observability_tags

  criteria {
    metric_namespace = "Microsoft.Network/virtualNetworkGateways"
    metric_name      = "AverageBandwidth"
    aggregation      = "Average"
    operator         = "GreaterThan"
    threshold        = 80000000 # 80 Mbps
  }

  action {
    action_group_id = azurerm_monitor_action_group.ops_alerts.id
  }
}
