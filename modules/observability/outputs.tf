# Archivo: modules/observability/outputs.tf

output "log_analytics_workspace_id" {
  description = "ID del Log Analytics Workspace centralizado"
  value       = azurerm_log_analytics_workspace.central.id
}

output "log_analytics_workspace_name" {
  description = "Nombre del Log Analytics Workspace centralizado"
  value       = azurerm_log_analytics_workspace.central.name
}

output "log_analytics_workspace_primary_shared_key" {
  description = "Clave compartida primaria del Log Analytics Workspace"
  value       = azurerm_log_analytics_workspace.central.primary_shared_key
  sensitive   = true
}

output "application_insights_id" {
  description = "ID del recurso Application Insights centralizado"
  value       = azurerm_application_insights.app_insights.id
}

output "application_insights_instrumentation_key" {
  description = "Instrumentation Key de Application Insights"
  value       = azurerm_application_insights.app_insights.instrumentation_key
  sensitive   = true
}

output "application_insights_connection_string" {
  description = "Connection String de Application Insights"
  value       = azurerm_application_insights.app_insights.connection_string
  sensitive   = true
}

output "action_group_id" {
  description = "ID del Action Group de monitorización y alertas"
  value       = azurerm_monitor_action_group.ops_alerts.id
}
