# Archivo: modules/networking/firewall_rules.tf

# =========================================================================
# AZURE FIREWALL POLICY RULE COLLECTION GROUPS (FLUJOS F1 - F7)
# =========================================================================

# -------------------------------------------------------------------------
# 1. NETWORK RULE COLLECTION GROUP (REGLAS DE RED / L4)
# -------------------------------------------------------------------------
resource "azurerm_firewall_policy_rule_collection_group" "network_rules" {
  provider           = azurerm.connectivity
  name               = "rcg-network-prod-swe"
  firewall_policy_id = azurerm_firewall_policy.fw_policy.id
  priority           = 200

  # Flujo F3: Conectividad Hibrida (On-Premises / VPN Gateway -> LZ)
  network_rule_collection {
    name     = "rc-hybrid-connectivity"
    priority = 210
    action   = "Allow"

    rule {
      name                  = "Allow-OnPrem-to-Hub-and-Spokes"
      protocols             = ["TCP", "UDP", "ICMP"]
      source_addresses      = ["172.16.0.0/16"]
      destination_addresses = ["10.0.0.0/12"]
      destination_ports     = ["*"]
    }
  }

  # Flujo F6: Comunicacion Este-Oeste entre Spokes a traves del Hub
  network_rule_collection {
    name     = "rc-spoke-to-spoke"
    priority = 220
    action   = "Allow"

    rule {
      name                  = "Allow-AKS-to-SharedServices"
      protocols             = ["TCP"]
      source_addresses      = ["10.0.4.0/22", "10.1.4.0/22"]
      destination_addresses = ["10.0.11.0/24", "10.1.11.0/24"]
      destination_ports     = ["443", "80", "5671"]
    }

    rule {
      name                  = "Allow-Apps-to-DataIA"
      protocols             = ["TCP"]
      source_addresses      = ["10.0.10.0/24", "10.1.10.0/24"]
      destination_addresses = ["10.0.8.0/23", "10.1.8.0/23"]
      destination_ports     = ["443", "1433", "6379"]
    }

    rule {
      name                  = "Allow-AKS-to-DataIA"
      protocols             = ["TCP"]
      source_addresses      = ["10.0.4.0/22", "10.1.4.0/22"]
      destination_addresses = ["10.0.8.0/23", "10.1.8.0/23"]
      destination_ports     = ["443", "1433", "6379"]
    }

    rule {
      name                  = "Allow-Management-Host-to-Spokes"
      protocols             = ["TCP"]
      source_addresses      = ["10.0.0.0/24", "10.1.0.0/24"]
      destination_addresses = ["10.0.4.0/22", "10.0.8.0/23", "10.0.10.0/24", "10.0.11.0/24", "10.1.4.0/22", "10.1.8.0/23", "10.1.10.0/24", "10.1.11.0/24"]
      destination_ports     = ["443", "22", "3389"]
    }
  }

  # Flujo F5: Acceso a Endpoints Privados (PaaS)
  network_rule_collection {
    name     = "rc-spoke-to-paas-endpoints"
    priority = 230
    action   = "Allow"

    rule {
      name                  = "Allow-Spokes-to-PrivateEndpoints"
      protocols             = ["TCP"]
      source_addresses      = ["10.0.0.0/12"]
      destination_addresses = ["10.0.1.0/24", "10.0.7.64/26", "10.0.8.0/25", "10.0.10.192/26", "10.0.11.0/25", "10.1.1.0/24", "10.1.7.96/27", "10.1.8.0/25", "10.1.10.192/26", "10.1.11.0/25"]
      destination_ports     = ["443", "1433", "5671", "6379"]
    }
  }

  # Flujo F4: Resolucion DNS Privada
  network_rule_collection {
    name     = "rc-dns-infrastructure"
    priority = 240
    action   = "Allow"

    rule {
      name                  = "Allow-DNS-PrivateResolver"
      protocols             = ["UDP", "TCP"]
      source_addresses      = ["10.0.0.0/12"]
      destination_addresses = ["10.0.3.0/27", "10.1.3.0/27", "168.63.129.16"]
      destination_ports     = ["53"]
    }
  }

  # Flujo F1: Publicacion y paso de App Gateway hacia Ingress / Backend Workloads (Regla L4 en Network Rules)
  network_rule_collection {
    name     = "rc-inbound-appgw-to-spokes"
    priority = 250
    action   = "Allow"

    rule {
      name                  = "Allow-AppGw-Inbound-to-Backends"
      protocols             = ["TCP"]
      source_addresses      = ["10.0.2.64/26", "10.1.2.64/26"]
      destination_addresses = ["10.0.4.0/22", "10.0.10.0/24", "10.1.4.0/22", "10.1.10.0/24"]
      destination_ports     = ["80", "443"]
    }
  }
}

# -------------------------------------------------------------------------
# 2. APPLICATION RULE COLLECTION GROUP (REGLAS DE APLICACION / L7)
# -------------------------------------------------------------------------
resource "azurerm_firewall_policy_rule_collection_group" "application_rules" {
  provider           = azurerm.connectivity
  name               = "rcg-application-prod-swe"
  firewall_policy_id = azurerm_firewall_policy.fw_policy.id
  priority           = 300

  # Flujo F7: Trafico Saliente a Internet Autorizado (Repositorios, CI/CD, MCR, Observabilidad)
  application_rule_collection {
    name     = "rc-egress-internet"
    priority = 310
    action   = "Allow"

    rule {
      name = "Allow-GitHub-and-DevOps"
      protocols {
        type = "Https"
        port = 443
      }
      protocols {
        type = "Http"
        port = 80
      }
      source_addresses = ["10.0.0.0/12"]
      destination_fqdns = [
        "github.com",
        "*.github.com",
        "*.githubusercontent.com",
        "dev.azure.com",
        "*.dev.azure.com"
      ]
    }

    rule {
      name = "Allow-Container-Registries"
      protocols {
        type = "Https"
        port = 443
      }
      source_addresses = ["10.0.0.0/12"]
      destination_fqdns = [
        "*.azurecr.io",
        "*.mcr.microsoft.com",
        "mcr.microsoft.com",
        "docker.io",
        "*.docker.io",
        "production.cloudflare.docker.com"
      ]
    }

    rule {
      name = "Allow-OS-Updates-and-Telemetry"
      protocols {
        type = "Https"
        port = 443
      }
      protocols {
        type = "Http"
        port = 80
      }
      source_addresses = ["10.0.0.0/12"]
      destination_fqdns = [
        "*.ubuntu.com",
        "security.ubuntu.com",
        "*.debian.org",
        "*.opinsights.azure.com",
        "*.oms.opinsights.azure.com",
        "*.microsoftonline.com",
        "*.azure.com"
      ]
    }
  }
}


