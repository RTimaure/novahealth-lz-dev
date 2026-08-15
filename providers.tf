# Archivo: providers.tf

terraform {
  required_version = ">= 1.5.0"
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

provider "azurerm" {
  features {}
}

provider "azuread" {}

# Aliases de proveedores para las 5 suscripciones físicas de la Demo
provider "azurerm" {
  alias           = "connectivity"
  subscription_id = local.target_subscriptions["connectivity"]
  features {}
}

provider "azurerm" {
  alias           = "identity"
  subscription_id = local.target_subscriptions["identity"]
  features {}
}

provider "azurerm" {
  alias           = "management"
  subscription_id = local.target_subscriptions["management"]
  features {}
}

provider "azurerm" {
  alias           = "production"
  subscription_id = local.target_subscriptions["production"]
  features {}
}

provider "azurerm" {
  alias           = "data_ai"
  subscription_id = local.target_subscriptions["data_ai"]
  features {}
}

# ¡AÑADE ESTE BLOQUE TEMPORAL ABAJO!
# Usará el mismo ID de suscripción, pero con el nombre que el estado viejo busca
provider "azurerm" {
  alias           = "data_ia"
  subscription_id = local.target_subscriptions["data_ai"] 
  features {}
}

