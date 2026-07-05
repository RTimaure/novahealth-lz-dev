# Archivo: modules/policy/versions.tf

terraform {
  required_version = ">= 1.0.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 3.0.0" # Asegura la compatibilidad con los nuevos recursos de políticas
    }
  }
}
