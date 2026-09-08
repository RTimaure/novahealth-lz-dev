locals {
  target_subscriptions = {
    connectivity      = var.connectivity_subscription_id
    identity          = var.identity_subscription_id
    management        = var.management_subscription_id
    production        = var.production_subscription_id
    platform_services = var.platform_services_subscription_id
  }
}

module "resource_groups" {
  source = "../../modules/resource_groups"

  primary_location = var.primary_location
  dr_location      = var.dr_location
  deployment_scope = var.deployment_scope

  providers = {
    azurerm.connectivity      = azurerm.connectivity
    azurerm.identity          = azurerm.identity
    azurerm.management        = azurerm.management
    azurerm.production        = azurerm.production
    azurerm.platform_services = azurerm.platform_services
  }
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
    azurerm.connectivity      = azurerm.connectivity
    azurerm.identity          = azurerm.identity
    azurerm.management        = azurerm.management
    azurerm.production        = azurerm.production
    azurerm.platform_services = azurerm.platform_services
  }

  depends_on = [module.resource_groups]
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

  providers = {
    azurerm = azurerm.management
  }

  depends_on = [module.resource_groups, module.networking]
}

