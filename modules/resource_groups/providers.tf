# Archivo: modules/resource_groups/providers.tf

terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
      configuration_aliases = [
        azurerm.connectivity,
        azurerm.identity,
        azurerm.management,
        azurerm.production,
        azurerm.platform_services
      ]
    }
  }
}