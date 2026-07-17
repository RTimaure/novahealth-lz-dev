# Archivo: modules/subscriptions/main.tf

terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
  }
}

# -------------------------------------------------------------------------
# 1. ASOCIACIÓN EN MODO ESTUDIANTE (MOVER AL MG RAÍZ NH-ROOT)
# -------------------------------------------------------------------------

resource "azurerm_management_group_subscription_association" "student_association" {
  count               = var.use_enterprise_subscriptions ? 0 : (var.student_subscription_id != "" ? 1 : 0)
  management_group_id = lookup(var.management_group_ids, "root", lookup(var.management_group_ids, "nh-root", ""))
  subscription_id     = startswith(var.student_subscription_id, "/subscriptions/") ? var.student_subscription_id : "/subscriptions/${var.student_subscription_id}"
}

# -------------------------------------------------------------------------
# 2. ASOCIACIÓN EN MODO ENTERPRISE BYOS
# -------------------------------------------------------------------------

locals {
  sub_to_mg_map = {
    for sub_key, sub_id in var.enterprise_subscriptions :
    sub_key => {
      subscription_id = sub_id
      management_group_id = var.management_group_ids[
        var.subscription_to_mg[sub_key]
      ]
    }
    if sub_id != "" && sub_id != null
  }
}

resource "azurerm_management_group_subscription_association" "enterprise_associations" {
  for_each            = var.use_enterprise_subscriptions ? local.sub_to_mg_map : {}
  management_group_id = each.value.management_group_id
  subscription_id     = startswith(each.value.subscription_id, "/subscriptions/") ? each.value.subscription_id : "/subscriptions/${each.value.subscription_id}"
}