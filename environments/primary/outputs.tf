output "rg_ids" {
	value = module.resource_groups.rg_ids
}

output "rg_names" {
	value = module.resource_groups.rg_names
}

output "vnets" {
	value = module.networking.vnets
}

output "subnets" {
	value = module.networking.subnets
}

output "nsgs" {
	value = module.networking.nsgs
}

output "vnet_peerings" {
	value = module.networking.vnet_peerings
}

output "firewall_public_ip" {
	value = module.networking.firewall_public_ip
}

output "bastion_public_ip" {
	value = module.networking.bastion_public_ip
}

output "vpngw_public_ip" {
	value = module.networking.vpngw_public_ip
}

output "data_subnets" {
	value = module.networking.data_subnets
}
