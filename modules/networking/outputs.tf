# Archivo: modules/networking/outputs.tf
/*
output "vnets" {
  description = "Diccionario con todas las Virtual Networks desplegadas (Prod, Non-Prod, DR, On-Premise)"
  value       = azurerm_virtual_network.vnet
}

output "subnets" {
  description = "Diccionario con todas las Subredes desplegadas, indexadas por la clave <vnet_key>-<subnet_name>"
  value       = azurerm_subnet.subnet
}
*/
output "resource_groups" {
  description = "Diccionario con todos los Resource Groups de red desplegados"
  value       = azurerm_resource_group.net_rg
}



output "vnets" {
  description = "Diccionario completo de Virtual Networks aprovisionadas"
  value       = azurerm_virtual_network.vnet
}

output "subnets" {
  description = "Diccionario completo de Subredes aplanadas aprovisionadas"
  value       = azurerm_subnet.subnet
}

output "route_tables" {
  description = "Diccionario con las User Defined Routes (UDRs) creadas para los Spokes"
  value       = azurerm_route_table.udr
}

output "vnet_peerings" {
  description = "Diccionario con los VNet Peerings (Hub-and-Spoke locales) desplegados"
  value       = azurerm_virtual_network_peering.peerings
}