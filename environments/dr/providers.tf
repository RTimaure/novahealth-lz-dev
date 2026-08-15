terraform {
	required_version = ">= 1.5.0"
	required_providers {
		azurerm = {
			source  = "hashicorp/azurerm"
			version = "~> 3.0"
		}
	}
}

provider "azurerm" {
	alias           = "connectivity"
	subscription_id = var.connectivity_subscription_id
	features {}
}

provider "azurerm" {
	alias           = "identity"
	subscription_id = var.identity_subscription_id
	features {}
}

provider "azurerm" {
	alias           = "management"
	subscription_id = var.management_subscription_id
	features {}
}

provider "azurerm" {
	alias           = "production"
	subscription_id = var.production_subscription_id
	features {}
}

provider "azurerm" {
	alias           = "data_ai"
	subscription_id = var.data_ai_subscription_id
	features {}
}
