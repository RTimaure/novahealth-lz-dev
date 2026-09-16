# Archivo: modules/rag_infrastructure/versions.tf
#
# Restricciones de proveedor propias del módulo. azurerm >= 3.90 es necesario
# para semantic_search_sku en azurerm_search_service y para la GA de
# azurerm_container_app_job. Estas versiones ya están resueltas en
# .terraform.lock.hcl (azurerm 3.90.0 / azuread 2.53.1), por lo que no
# introduce cambios de proveedor en el resto de la Landing Zone.

terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.90"
    }
    azuread = {
      source  = "hashicorp/azuread"
      version = "~> 2.0"
    }
    null = {
      source  = "hashicorp/null"
      version = "~> 3.2"
    }
  }
}
