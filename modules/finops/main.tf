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
  # sub_key asocia cada partida a la suscripción real anfitriona en var.target_subscriptions
  subscription_budgets = {
    connectivity = {
      display_name = "Budget-Connectivity-Sub"
      sub_key      = "connectivity"
      amount       = 500
      costCenter   = "CC-001"
    }
    identity = {
      display_name = "Budget-Identity-Sub"
      sub_key      = "identity"
      amount       = 300
      costCenter   = "CC-002"
    }
    security = {
      display_name = "Budget-Security-Sub"
      sub_key      = "management"
      amount       = 350
      costCenter   = "CC-003"
    }
    management = {
      display_name = "Budget-Management-Sub"
      sub_key      = "management"
      amount       = 400
      costCenter   = "CC-004"
    }
    # Segregación por entorno para CC-005 en la suscripción de producción/workloads
    production = {
      display_name = "Budget-Prod-Sub"
      sub_key      = "production"
      amount       = 850
      costCenter   = "CC-005"
      environment  = "prod"
    }
    development = {
      display_name = "Budget-Dev-Sub"
      sub_key      = "production"
      amount       = 400
      costCenter   = "CC-005"
      environment  = "dev"
    }
    qa = {
      display_name = "Budget-QA-Sub"
      sub_key      = "production"
      amount       = 200
      costCenter   = "CC-005"
      environment  = "qa"
    }
    telemedicine = {
      display_name = "Budget-Telemedicine-Sub"
      sub_key      = "production"
      amount       = 300
      costCenter   = "CC-006"
    }
    data_ai = {
      display_name = "Budget-Data-IA-Sub"
      sub_key      = "data_ai"
      amount       = 435
      costCenter   = "CC-007"
    }
    shared_services = {
      display_name = "Budget-SharedServices-Sub"
      sub_key      = "production"
      amount       = 250
      costCenter   = "CC-008"
    }
    sandbox = {
      display_name = "Budget-Sandbox-Sub"
      sub_key      = "management"
      amount       = 100
      costCenter   = "CC-009"
    }
    # Control financiero del licenciamiento Entra ID P2 (PIM) discriminado por workload
    entra_id_p2_pim = {
      display_name = "Budget-EntraID-P2-PIM"
      sub_key      = "identity"
      amount       = 120
      costCenter   = "CC-002"
      workload     = "identity-pim"
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

  # Resuelve la suscripción real correspondiente mediante sub_key
  subscription_id = lookup(local.format_sub_scope, each.value.sub_key)

  amount     = each.value.amount
  time_grain = "Monthly"

  time_period {
    #start_date = "2026-09-01T00:00:00Z"
    start_date = "${formatdate("YYYY-MM", timestamp())}-01T00:00:00Z"
    end_date   = "2030-12-31T00:00:00Z"
  }

  # Filtro combinado: costCenter obligatorio + environment/workload condicionales si existen
  dynamic "filter" {
    for_each = lookup(each.value, "costCenter", null) != null ? [1] : []
    content {
      tag {
        name   = "costCenter"
        values = [each.value.costCenter]
      }

      dynamic "tag" {
        for_each = lookup(each.value, "environment", null) != null ? [each.value.environment] : []
        content {
          name   = "environment"
          values = [tag.value]
        }
      }

      dynamic "tag" {
        for_each = lookup(each.value, "workload", null) != null ? [each.value.workload] : []
        content {
          name   = "workload"
          values = [tag.value]
        }
      }
    }
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