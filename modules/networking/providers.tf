# Archivo: modules/networking/providers.tf

# Este archivo es crucial dentro del módulo para decirle a Terraform
# que este módulo espera recibir múltiples alias de proveedores.
terraform {
  required_providers {
    azurerm = {
      source                = "hashicorp/azurerm"
      version               = "~> 3.0"
      configuration_aliases = [
        azurerm.connectivity,
        azurerm.data_ia,
        azurerm.production
      ]
   
    }
  }
}