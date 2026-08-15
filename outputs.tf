# Archivo: modules/networking/outputs.tf

output "vnet_ids" {
  description = "Mapa global de IDs de las Redes Virtuales desplegadas (Hub, Data e Infraestructura)"
  value       = module.networking.vnets
}

output "subnet_ids" {
  description = "Mapa global de IDs de las Subredes desplegadas"
  value       = module.networking.subnets
}

output "nsg_ids" {
  description = "Mapa global de IDs de los Network Security Groups desplegados"
  value       = module.networking.nsgs
}

output "vnet_peering_ids" {
  description = "Mapa global de IDs de las conexiones VNet Peering"
  value       = module.networking.vnet_peerings
}

output "firewall_public_ip" {
  description = "IP pública del Azure Firewall Perimetral"
  value       = module.networking.firewall_public_ip
}

output "bastion_public_ip" {
  description = "IP pública del Azure Bastion Host"
  value       = module.networking.bastion_public_ip
}

output "appgw_public_ip" {
  description = "IP pública del Application Gateway WAF"
  value       = null
}

