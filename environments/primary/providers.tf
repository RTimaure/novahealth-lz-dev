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

  # ESTE ES EL BLOQUE CLAVE PARA COMPARTIR EL ESTADO
  backend "azurerm" {
    resource_group_name  = "rg-terraform-tfm-state" # El grupo que creó en el Paso 1
    storage_account_name = "sttfmstateshared"       # El nombre de nuestro Storage Account
    container_name       = "terraform-state"        # El nombre del contenedor
    key                  = "landingzone.tfstate"    # El nombre que tendrá el archivo en la nube
  }
}

provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}

provider "azurerm" {
  alias           = "connectivity"
  subscription_id = var.connectivity_subscription_id
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}

provider "azurerm" {
  alias           = "identity"
  subscription_id = var.identity_subscription_id
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}

provider "azurerm" {
  alias           = "management"
  subscription_id = var.management_subscription_id
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}

provider "azurerm" {
  alias           = "production"
  subscription_id = var.production_subscription_id
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}

provider "azurerm" {
  alias           = "data_ai"
  subscription_id = var.data_ai_subscription_id
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}

provider "azuread" {}
