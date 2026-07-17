# Archivo: modules/networking/outputs.tf

output "vnets" {
  description = "Diccionario con todas las Virtual Networks desplegadas (Prod, Non-Prod, DR, On-Premise)"
  value       = azurerm_virtual_network.vnet
}

output "subnets" {
  description = "Diccionario con todas las Subredes desplegadas, indexadas por la clave <vnet_key>-<subnet_name>"
  value       = azurerm_subnet.subnet
}

output "resource_groups" {
  description = "Diccionario con todos los Resource Groups de red desplegados"
  value       = azurerm_resource_group.net_rg
}