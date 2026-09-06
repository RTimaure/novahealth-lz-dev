# Archivo: modules/networking/outputs.tf


output "vnets" {
  description = "Mapa de todos los IDs de las VNets desplegadas."
  value = merge(
    { for k, v in azurerm_virtual_network.hub_prod : k => v.id },
    // { for k, v in azurerm_virtual_network.hub_nprod : k => v.id },
    { for k, v in azurerm_virtual_network.data_prod : k => v.id },
    //  { for k, v in azurerm_virtual_network.data_nprod : k => v.id },
    { for k, v in azurerm_virtual_network.prod : k => v.id }
  )
}

output "subnets" {
  description = "Mapa de todos los IDs de las Subredes desplegadas."
  value = merge(
    { for k, v in azurerm_subnet.hub_prod : k => v.id },
    // { for k, v in azurerm_subnet.hub_nprod : k => v.id },
    { for k, v in azurerm_subnet.data_prod : k => v.id },
    // { for k, v in azurerm_subnet.data_nprod : k => v.id },
    { for k, v in azurerm_subnet.prod : k => v.id }
  )
}
/*
output "nsgs" {
  description = "Mapa de todos los IDs de los NSGs desplegados."
  value = merge(
    { for k, v in azurerm_network_security_group.hub_nsgs : k => v.id },
    { for k, v in azurerm_network_security_group.data_nsgs : k => v.id },
    { for k, v in azurerm_network_security_group.prod_nsgs : k => v.id }
  )
}
*/


output "nsgs" {
  description = "Mapa de todos los NSGs desplegados."
  value = merge(
    azurerm_network_security_group.hub_nsgs_prod,
    // azurerm_network_security_group.hub_nsgs_nprod,
    azurerm_network_security_group.data_nsgs_prod,
    // azurerm_network_security_group.data_nsgs_nprod,
    azurerm_network_security_group.prod_nsgs
  )
}


output "route_tables" {
  description = "Mapa de todas las Tablas de Rutas (Route Tables) desplegadas."
  value = {
    hub_mngt_prod = azurerm_route_table.hub_mngt_prod.id
    //  hub_mngt_nprod = azurerm_route_table.hub_mngt_nprod.id
    aks_prod = azurerm_route_table.aks_prod.id
    //  aks_nprod      = azurerm_route_table.aks_nprod.id
    data_prod = azurerm_route_table.data_prod.id
    //  data_nprod     = azurerm_route_table.data_nprod.id
    apps_prod = azurerm_route_table.apps_prod.id
    // apps_nprod     = azurerm_route_table.apps_nprod.id
    shared_prod = azurerm_route_table.shared_prod.id
    // shared_nprod   = azurerm_route_table.shared_nprod.id
  }
}

output "vnet_peerings" {
  description = "Mapa de todos los IDs de los VNet Peerings."
  value = merge(
    { for k, v in azurerm_virtual_network_peering.hub_to_prod_prod : k => v.id },
    // { for k, v in azurerm_virtual_network_peering.hub_to_prod_nprod : k => v.id },
    // { for k, v in azurerm_virtual_network_peering.prod_to_hub : k => v.id },
    { for k, v in azurerm_virtual_network_peering.hub_to_data_prod : k => v.id },
    // { for k, v in azurerm_virtual_network_peering.hub_to_data_nprod : k => v.id },
    { for k, v in azurerm_virtual_network_peering.data_to_hub_prod : k => v.id },
    // { for k, v in azurerm_virtual_network_peering.data_to_hub_nprod : k => v.id },
    { for k, v in azurerm_virtual_network_peering.hub_to_shared_prod : k => v.id },
    { for k, v in azurerm_virtual_network_peering.shared_to_hub_prod : k => v.id }
  )
}

output "firewall_public_ip" {
  description = "Dirección IP Pública del Azure Firewall."
  value       = azurerm_public_ip.firewall_pip.ip_address
}

output "bastion_public_ip" {
  description = "Dirección IP Pública de Azure Bastion."
  value       = null
}

output "vpngw_public_ip" {
  description = "Dirección IP Pública del VPN Gateway."
  value       = null
}

/*
output "data_subnets" {
  value = merge(local.data_subnets_prod, local.data_subnets_nprod)
}
*/
output "dns_resolver_id" {
  description = "ID de Azure Private DNS Resolver"
  value       = azurerm_private_dns_resolver.hub_dns_resolver.id
}

output "private_dns_zones" {
  description = "Mapa con los IDs de las Zonas DNS Privadas"
  value       = { for k, v in azurerm_private_dns_zone.dns_zones : k => v.id }
}

output "firewall_id" {
  description = "ID del Azure Firewall"
  value       = azurerm_firewall.fw.id
}

output "application_gateway_id" {
  description = "ID del Application Gateway"
  value       = azurerm_application_gateway.appgw.id
}

output "vpn_gateway_id" {
  description = "ID del VPN Gateway"
  value       = azurerm_virtual_network_gateway.vpngw.id
}

output "bastion_id" {
  description = "ID de Azure Bastion"
  value       = azurerm_bastion_host.bastion.id
}

output "management_vm_id" {
  description = "ID de la Virtual Machine de Administración (Hopping Host)"
  value       = null
}

/*
output "management_vm_private_ip" {
  description = "Dirección IP Privada del Hopping Host en el Hub"
  value       = azurerm_network_interface.mngt_vm_nic.private_ip_address
}
*/


