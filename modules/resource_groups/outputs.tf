
# Archivo: modules/resource_groups/outputs.tf

output "rg_ids" {
  description = "Mapa global de IDs de todos los Resource Groups desplegados"
  value = merge(
    { for k, v in azurerm_resource_group.connectivity : k => v.id },
    { for k, v in azurerm_resource_group.identity : k => v.id },
    { for k, v in azurerm_resource_group.management : k => v.id },
    { for k, v in azurerm_resource_group.production : k => v.id },
    { for k, v in azurerm_resource_group.platform_services : k => v.id }
  )
}

output "rg_names" {
  description = "Mapa global de Nombres de todos los Resource Groups desplegados"
  value = merge(
    { for k, v in azurerm_resource_group.connectivity : k => v.name },
    { for k, v in azurerm_resource_group.identity : k => v.name },
    { for k, v in azurerm_resource_group.management : k => v.name },
    { for k, v in azurerm_resource_group.production : k => v.name },
    { for k, v in azurerm_resource_group.platform_services : k => v.name }
  )
}

output "rg_tags" {
  description = "Mapa global de Tags de todos los Resource Groups desplegados"
  value = merge(
    { for k, v in azurerm_resource_group.connectivity : k => v.tags },
    { for k, v in azurerm_resource_group.identity : k => v.tags },
    { for k, v in azurerm_resource_group.management : k => v.tags },
    { for k, v in azurerm_resource_group.production : k => v.tags },
    { for k, v in azurerm_resource_group.platform_services : k => v.tags }
  )
}