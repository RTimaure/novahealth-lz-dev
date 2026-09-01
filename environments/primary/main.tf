
locals {
	target_subscriptions = {
		connectivity = var.connectivity_subscription_id
		identity     = var.identity_subscription_id
		management   = var.management_subscription_id
		production   = var.production_subscription_id
		data_ai      = var.data_ai_subscription_id
	}

	root_mg_id     = lookup(module.management_groups.management_group_ids, "root", "nh-root")
	security_mg_id = lookup(module.management_groups.management_group_ids, "security", "nh-security")
}

module "management_groups" {
	source = "../../modules/management_groups"
}

module "subscriptions" {
	source = "../../modules/subscriptions"

	management_group_ids        = module.management_groups.management_group_ids
	use_enterprise_subscriptions = var.use_enterprise_subscriptions
	enterprise_subscriptions     = var.enterprise_subscriptions
	subscription_to_mg           = var.subscription_to_mg
	student_subscription_id      = var.student_subscription_id

	depends_on = [module.management_groups]
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

	depends_on = [module.subscriptions]
}

module "policy" {
	source = "../../modules/policy"

	root_mg_id           = local.root_mg_id
	platform_mg_id       = lookup(module.management_groups.management_group_ids, "platform", "nh-platform")
	landing_zones_mg_id  = lookup(module.management_groups.management_group_ids, "landing_zones", "nh-landing-zones")
	management_group_ids = module.management_groups.management_group_ids
	target_subscriptions = local.target_subscriptions
	allowed_locations    = [var.location]

	depends_on = [module.management_groups]
}

module "rbac" {
	source = "../../modules/rbac"

	root_mg_id                      = local.root_mg_id
	security_mg_id                  = local.security_mg_id
	target_subscriptions            = local.target_subscriptions
	cicd_service_principal_object_id = var.cicd_service_principal_object_id

	depends_on = [module.policy]
}

module "networking" {
	source               = "../../modules/networking"
	location             = var.location
	target_subscriptions = local.target_subscriptions
	resource_group_names = module.resource_groups.rg_names
	resource_group_tags  = module.resource_groups.rg_tags

	enable_global_peering = var.enable_global_peering
	remote_hub_vnet_id    = var.remote_hub_vnet_id
	tags                  = var.tags

	providers = {
		azurerm.connectivity = azurerm.connectivity
		azurerm.identity     = azurerm.identity
		azurerm.management   = azurerm.management
		azurerm.production   = azurerm.production
		azurerm.data_ai      = azurerm.data_ai
	}

	depends_on = [module.resource_groups]
}


module "finops" {
	source = "../../modules/finops"

	target_subscriptions = local.target_subscriptions
	notification_emails   = ["finops@novahealth.com"]

	depends_on = [module.networking]
}

module "observability" {
	source = "../../modules/observability"

	location             = var.location
	resource_group_names = module.resource_groups.rg_names
	resource_group_tags  = module.resource_groups.rg_tags
	tags                 = var.tags
	notification_email   = "ops-alerts@novahealth.com"

	diagnostic_target_resources = {
		firewall_id            = module.networking.firewall_id
		application_gateway_id = module.networking.application_gateway_id
		vpn_gateway_id         = module.networking.vpn_gateway_id
		bastion_id             = module.networking.bastion_id
		dns_resolver_id        = module.networking.dns_resolver_id
	}

	# 🆕(Dile a Terraform explícitamente qué recursos existen)
  	enabled_features = {
		firewall            = true
		application_gateway = true
		vpn_gateway         = true
		bastion             = true
		dns_resolver        = true
  	}	

	providers = {
		azurerm = azurerm.management
	}

	depends_on = [module.resource_groups, module.networking]
}
