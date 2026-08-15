# Archivo: modules/policy/outputs.tf

output "custom_policy_definition_ids" {
  description = "Mapa con los IDs de todas las definiciones personalizadas creadas"
  value = {
    deny_public_ip         = azurerm_policy_definition.deny_public_ip.id
    enable_sentinel        = azurerm_policy_definition.enable_sentinel.id
    enforce_ddos           = azurerm_policy_definition.enforce_ddos.id
    private_endpoints_only = azurerm_policy_definition.private_endpoints_only.id
    deny_public_net_all    = azurerm_policy_definition.deny_public_net_all.id
    enforce_azure_firewall = azurerm_policy_definition.enforce_azure_firewall.id
    require_pe_storage     = azurerm_policy_definition.require_pe_storage.id
    require_pe_kv          = azurerm_policy_definition.require_pe_kv.id
    #naming_convention      = azurerm_policy_definition.naming_convention.id
    naming_convention      = azurerm_policy_definition.enforce_naming.id
  }
}

output "policy_assignment_ids" {
  description = "Mapa con los IDs de todas las asignaciones de Azure Policy"
  value = {
    for k, v in azurerm_management_group_policy_assignment.builtin : k => v.id
  }
}

output "policy_assignment_identities" {
  description = "Mapa de identidades administradas para remediación DINE"
  value = {
    for k, v in azurerm_management_group_policy_assignment.builtin : k => try(v.identity[0].principal_id, null) if can(v.identity[0].principal_id)
  }
}