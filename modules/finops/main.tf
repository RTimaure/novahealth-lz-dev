# Archivo: modules/finops/main.tf

terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
  }
}

locals {
  # Tabla de presupuestos operacionales alineada con los Centros de Coste oficiales CC-001 a CC-009
  subscription_budgets = {
    connectivity = {
      display_name = "Budget-Connectivity-Sub"
      amount       = 500
      cost_center  = "CC-001"
    }
    identity = {
      display_name = "Budget-Identity-Sub"
      amount       = 300
      cost_center  = "CC-002"
    }
    security = {
      display_name = "Budget-Security-Sub"
      amount       = 350
      cost_center  = "CC-003"
    }
    management = {
      display_name = "Budget-Management-Sub"
      amount       = 400
      cost_center  = "CC-004"
    }
    production = {
      display_name = "Budget-Prod-Sub"
      amount       = 850
      cost_center  = "CC-005"
    }
    telemedicine = {
      display_name = "Budget-Telemedicine-Sub"
      amount       = 300
      cost_center  = "CC-006"
    }
    data_ai = {
      display_name = "Budget-Data-IA-Sub"
      amount       = 435
      cost_center  = "CC-007"
    }
    shared_services = {
      display_name = "Budget-SharedServices-Sub"
      amount       = 250
      cost_center  = "CC-008"
    }
    development = {
      display_name = "Budget-Dev-Sub"
      amount       = 400
      cost_center  = "CC-005"
    }
    qa = {
      display_name = "Budget-QA-Sub"
      amount       = 200
      cost_center  = "CC-005"
    }
    sandbox = {
      display_name = "Budget-Sandbox-Sub"
      amount       = 100
      cost_center  = "CC-009"
    }
    # Control financiero del licenciamiento Entra ID P2 (PIM)
    entra_id_p2_pim = {
      display_name = "Budget-EntraID-P2-PIM"
      amount       = 120
      cost_center  = "CC-002"
    }
  }

  # Normalización del scope al estándar de Azure Resource Manager (/subscriptions/UUID)
  format_sub_scope = {
    for k, v in var.target_subscriptions :
    k => startswith(v, "/subscriptions/") ? v : "/subscriptions/${v}"
  }
}

resource "azurerm_consumption_budget_subscription" "lz_budgets" {
  for_each = local.subscription_budgets
  name     = each.value.display_name

  # Para los presupuestos de suscripción normales toma su propia ID. 
  # Para la partida global de Entra ID P2 lo imputa a la suscripción de Identity (Platform).
  subscription_id = lookup(
    local.format_sub_scope,
    each.key == "entra_id_p2_pim" ? "identity" : each.key,
    lookup(local.format_sub_scope, "identity")
  )

  amount     = each.value.amount
  time_grain = "Monthly"

  time_period {
  start_date = "${formatdate("YYYY-MM", timestamp())}-01T00:00:00Z"
  end_date   = "2030-12-31T00:00:00Z"
}

  # Alerta temprana: 50% del presupuesto mensual (Actual)
  notification {
    enabled        = true
    threshold      = 50.0
    operator       = "GreaterThan"
    threshold_type = "Actual"
    contact_emails = var.notification_emails
  }

  # Alerta preventiva: 80% del presupuesto mensual (Actual)
  notification {
    enabled        = true
    threshold      = 80.0
    operator       = "GreaterThan"
    threshold_type = "Actual"
    contact_emails = var.notification_emails
  }

  # Alerta crítica: 100% del presupuesto mensual (Actual)
  notification {
    enabled        = true
    threshold      = 100.0
    operator       = "GreaterThan"
    threshold_type = "Actual"
    contact_emails = var.notification_emails
  }

  # Alerta preventiva de pronóstico: 80% del presupuesto mensual (Forecasted)
  notification {
    enabled        = true
    threshold      = 80.0
    operator       = "GreaterThan"
    threshold_type = "Forecasted"
    contact_emails = var.notification_emails
  }

  # Alerta crítica de pronóstico: 100% del presupuesto mensual (Forecasted)
  notification {
    enabled        = true
    threshold      = 100.0
    operator       = "GreaterThan"
    threshold_type = "Forecasted"
    contact_emails = var.notification_emails
  }
}
