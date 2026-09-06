terraform {
  required_version = ">= 1.5.0"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
  }

  # Remote state, isolated per environment via a distinct key.
  # Values for resource_group_name / storage_account_name / container_name
  # are intentionally omitted here and must be supplied at `terraform init`
  # time via `-backend-config` (see .github/workflows/terraform-apply.yml),
  # so the same code can target different backend storage per environment
  # without hardcoding secrets/state locations in version control.
  backend "azurerm" {
    key = "dr.tfstate"
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
