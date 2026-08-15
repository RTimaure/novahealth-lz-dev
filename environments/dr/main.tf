locals {
	target_subscriptions = {
		connectivity = var.connectivity_subscription_id
		identity     = var.identity_subscription_id
		management   = var.management_subscription_id
		production   = var.production_subscription_id
		data_ai      = var.data_ai_subscription_id
	}
}

module "resource_groups" {
	source = "../../modules/resource_groups"

	primary_location = var.primary_location
	dr_location      = var.dr_location
	deployment_scope = var.deployment_scope

	providers = {
		azurerm.connectivity = azurerm.connectivity
		azurerm.identity     = azurerm.identity
		azurerm.management   = azurerm.management
		azurerm.production   = azurerm.production
		azurerm.data_ai      = azurerm.data_ai
	}
}

module "networking" {
	source               = "../../modules/networking"
	location             = var.location
	target_subscriptions = local.target_subscriptions
	resource_group_names = module.resource_groups.rg_names

	enable_global_peering = var.enable_global_peering
	remote_hub_vnet_id    = var.remote_hub_vnet_id

	tags = merge(
		var.tags,
		{
			environment  = "dr"
			project      = "NovaHealth-LandingZone"
			region       = "WestEurope"
			cost-center  = "IT-001"
			businessUnit = "HospitalSystems"
			criticality  = "Critical"
			owner        = "grp-novahealth-network-team"
		}
	)

	providers = {
		azurerm.connectivity = azurerm.connectivity
		azurerm.identity     = azurerm.identity
		azurerm.management   = azurerm.management
		azurerm.production   = azurerm.production
		azurerm.data_ai      = azurerm.data_ai
	}

	depends_on = [module.resource_groups]
}

