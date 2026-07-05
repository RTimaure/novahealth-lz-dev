# Archivo: modules/policy/definitions_lz_tagging.tf

# -------------------------------------------------------------------------
# 1. DIRECTIVAS DE ETIQUETADO OBLIGATORIO (MODULAR CON FOR_EACH)
# -------------------------------------------------------------------------

locals {
  required_tags = {
    "Environment" = {
      display_name = "Require Tag: Environment"
      description  = "Obliga el tag Environment para identificación del entorno (Prod/Dev/QA/Sandbox)"
    }
    "BusinessUnit" = {
      display_name = "Require Tag: BusinessUnit"
      description  = "Obliga el tag BusinessUnit para asignación de costes por área de negocio"
    }
    "CostCenter" = {
      display_name = "Require Tag: CostCenter"
      description  = "Obliga el tag CostCenter para trazabilidad financiera y control de costes"
    }
    "Criticality" = {
      display_name = "Require Tag: Criticality"
      description  = "Obliga el tag Criticality para clasificación y priorización de recursos"
    }
    "Region" = {
      display_name = "Require Tag: Region"
      description  = "Obliga el tag Region para identificar la ubicación del recurso (RGPD)"
    }
  }
}

resource "azurerm_policy_definition" "require_tags" {
  for_each = local.required_tags

  name                = "nh-req-tag-${lower(each.key)}"
  policy_type         = "Custom"
  mode                = "Indexed"
  display_name        = each.value.display_name
  description         = each.value.description
  management_group_id = var.root_mg_id

  metadata = <<METADATA
    {
      "category": "LZ-Tagging",
      "version": "1.0.0"
    }
METADATA

  policy_rule = <<RULE
    {
      "if": {
        "field": "tags['${each.key}']",
        "exists": "false"
      },
      "then": {
        "effect": "deny"
      }
    }
RULE
}

# -------------------------------------------------------------------------
# 2. DIRECTIVA DE CONVENCIÓN DE NOMBRES CORPORATIVA
# -------------------------------------------------------------------------

resource "azurerm_policy_definition" "naming_convention" {
  name                = "nh-enforce-naming"
  policy_type         = "Custom"
  mode                = "Indexed"
  display_name        = "Enforce Resource Naming Convention"
  description         = "Valida que los recursos cumplan el patrón corporativo <tipo>-<app>-<env>-<region>-<num>"
  management_group_id = var.root_mg_id

  metadata = <<METADATA
    {
      "category": "LZ-Tagging",
      "version": "1.0.0"
    }
METADATA

  policy_rule = <<RULE
    {
      "if": {
        "not": {
          "field": "name",
          "match": "?*-?*-?*-?*-###"
        }
      },
      "then": {
        "effect": "deny"
      }
    }
RULE
}