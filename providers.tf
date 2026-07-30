
# Archivo: providers.tf

terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
      
    }
    azuread = {
      source  = "hashicorp/azuread"
      version = "~> 2.0"
    }
   
  }
}

# Proveedor por defecto
provider "azurerm" {
  features {}
   skip_provider_registration = true
}

# ---------------------------------------------------------
# ALIAS MULTI-SUSCRIPCIÓN PARA LANDING ZONES
# ---------------------------------------------------------
provider "azurerm" {
  alias           = "connectivity"
  subscription_id = local.target_subscriptions["connectivity"]
  features {}
}

provider "azurerm" {
  alias           = "data_ia"
  subscription_id = local.target_subscriptions["data_ai"]
  features {}
}

provider "azurerm" {
  alias           = "production"
  subscription_id = local.target_subscriptions["production"]
  features {}
}

provider "azurerm" {
  alias           = "management"
  subscription_id = local.target_subscriptions["management"]
  features {}
}