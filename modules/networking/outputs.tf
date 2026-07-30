# Archivo: modules/networking/outputs.tf

output "resource_groups" {
  description = "Mapa de todos los IDs de los Resource Groups de red desplegados."
  value = merge(
    { for k, v in azurerm_resource_group.hub : k => v.id },
    { for k, v in azurerm_resource_group.data : k => v.id },
    { for k, v in azurerm_resource_group.prod : k => v.id }
  )
}

output "vnets" {
  description = "Mapa de todos los IDs de las VNets desplegadas."
  value = merge(
    { for k, v in azurerm_virtual_network.hub : k => v.id },
    { for k, v in azurerm_virtual_network.data : k => v.id },
    { for k, v in azurerm_virtual_network.prod : k => v.id }
  )
}

output "subnets" {
  description = "Mapa de todos los IDs de las Subredes desplegadas."
  value = merge(
    { for k, v in azurerm_subnet.hub : k => v.id },
    { for k, v in azurerm_subnet.data : k => v.id },
    { for k, v in azurerm_subnet.prod : k => v.id }
  )
}

output "nsgs" {
  description = "Mapa de todos los IDs de los NSGs desplegados."
  value = merge(
    { for k, v in azurerm_network_security_group.hub_nsgs : k => v.id },
    { for k, v in azurerm_network_security_group.data_nsgs : k => v.id },
    { for k, v in azurerm_network_security_group.prod_nsgs : k => v.id }
  )
}

output "route_tables" {
  description = "Mapa temporalmente vacío para mantener contrato con la raíz."
  value       = {}
}

output "vnet_peerings" {
  description = "Mapa de todos los IDs de los VNet Peerings."
  value = merge(
    { for k, v in azurerm_virtual_network_peering.hub_to_prod : k => v.id },
    { for k, v in azurerm_virtual_network_peering.prod_to_hub : k => v.id },
    { for k, v in azurerm_virtual_network_peering.hub_to_data : k => v.id },
    { for k, v in azurerm_virtual_network_peering.data_to_hub : k => v.id }
  )
}

output "firewall_public_ip" {
  description = "Dirección IP Pública del Azure Firewall."
  value       = azurerm_public_ip.firewall_pip.ip_address
}

output "bastion_public_ip" {
  description = "Dirección IP Pública de Azure Bastion."
  value       = azurerm_public_ip.bastion_pip.ip_address
}

output "vpngw_public_ip" {
  description = "Dirección IP Pública del VPN Gateway."
  value       = azurerm_public_ip.vpngw_pip.ip_address
}