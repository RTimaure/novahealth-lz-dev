# Archivo: modules/networking/firewall_rules.tf

# =========================================================================
# AZURE FIREWALL POLICY RULE COLLECTION GROUPS (MATRIZ ESTRICTA CSV)
# =========================================================================

# -------------------------------------------------------------------------
# 1. NETWORK RULE COLLECTION GROUP (REGLAS DE RED / L4)
# -------------------------------------------------------------------------
resource "azurerm_firewall_policy_rule_collection_group" "network_rules" {
  provider           = azurerm.connectivity
  name               = "rcg-network-prod-swe"
  firewall_policy_id = azurerm_firewall_policy.fw_policy.id
  priority           = 200

  # -----------------------------------------------------------------------
  # 0. REGLAS EXPLÍCITAS DE DENEGACIÓN (DEFAULT DENY / ZERO TRUST SEGÚN CSV)
  # -----------------------------------------------------------------------
  network_rule_collection {
    name     = "rc-explicit-deny-rules"
    priority = 205
    action   = "Deny"

    rule {
      name                  = "Deny-Apps-to-AKS-Direct"
      protocols             = ["Any"]
      source_addresses      = ["10.0.10.0/24"]
      destination_addresses = ["10.0.4.0/22"]
      destination_ports     = ["*"]
    }

    rule {
      name                  = "Deny-Apps-to-DataIA-Direct"
      protocols             = ["Any"]
      source_addresses      = ["10.0.10.0/24"]
      destination_addresses = ["10.0.8.0/23"]
      destination_ports     = ["*"]
    }

    rule {
      name                  = "Deny-AKS-to-SharedServices-Direct"
      protocols             = ["Any"]
      source_addresses      = ["10.0.4.0/22"]
      destination_addresses = ["10.0.11.0/24"]
      destination_ports     = ["*"]
    }

    rule {
      name                  = "Deny-Direct-Admin-Internet"
      protocols             = ["TCP"]
      source_addresses      = ["*"]
      destination_addresses = ["10.0.0.0/12"]
      destination_ports     = ["22", "3389"]
    }
  }

  # -----------------------------------------------------------------------
  # F1: Publicación segura desde Application Gateway (WAF) hacia AKS Ingress y Apps
  # Origen: snet-hub-appgw-prod-swe (10.0.2.64/26)
  # Destino: snet-aks-ingress-prod-swe (10.0.7.0/26) y snet-apps-aca-prod-swe (10.0.10.0/25)
  # -----------------------------------------------------------------------
  network_rule_collection {
    name     = "rc-inbound-appgw-to-spokes"
    priority = 210
    action   = "Allow"

    rule {
      name                  = "Allow-AppGw-to-AKSIngress-HTTPS"
      protocols             = ["TCP"]
      source_addresses      = ["10.0.2.64/26"]
      destination_addresses = ["10.0.7.0/26"]
      destination_ports     = ["443"]
    }

    rule {
      name                  = "Allow-AppGw-to-Apps-HTTPS"
      protocols             = ["TCP"]
      source_addresses      = ["10.0.2.64/26"]
      destination_addresses = ["10.0.10.0/25"]
      destination_ports     = ["443"]
    }
  }

  # -----------------------------------------------------------------------
  # F2: Administración Segura (Hopping Host hacia AKS Private API y PEs)
  # Origen: snet-hub-mngt-prod-swe (10.0.0.0/24)
  # Destino: AKS Private API (10.0.7.64/26), Shared PE (10.0.11.0/25), Hub PE (10.0.1.0/24)
  # -----------------------------------------------------------------------
  network_rule_collection {
    name     = "rc-management-access"
    priority = 220
    action   = "Allow"

    rule {
      name                  = "Allow-HoppingHost-to-AKSPrivateAPI"
      protocols             = ["TCP"]
      source_addresses      = ["10.0.0.0/24"]
      destination_addresses = ["10.0.7.64/26"]
      destination_ports     = ["443"]
    }

    rule {
      name                  = "Allow-HoppingHost-to-SharedACR"
      protocols             = ["TCP"]
      source_addresses      = ["10.0.0.0/24"]
      destination_addresses = ["10.0.11.0/25"]
      destination_ports     = ["443"]
    }

    rule {
      name                  = "Allow-HoppingHost-to-HubPE"
      protocols             = ["TCP"]
      source_addresses      = ["10.0.0.0/24"]
      destination_addresses = ["10.0.1.0/24"]
      destination_ports     = ["443"]
    }
  }

  # -----------------------------------------------------------------------
  # F3: Conectividad Híbrida (On-Premises hacia VPN Gateway, Hub y Spokes)
  # Origen: Red On-Premises (172.16.0.0/16)
  # Destino: Hub y Spokes (10.0.0.0/22, 10.0.4.0/22, 10.0.8.0/23, 10.0.10.0/24, 10.0.11.0/24)
  # -----------------------------------------------------------------------
  network_rule_collection {
    name     = "rc-hybrid-connectivity"
    priority = 230
    action   = "Allow"

    rule {
      name                  = "Allow-OnPrem-to-LZ-Resources"
      protocols             = ["TCP", "UDP", "ICMP"]
      source_addresses      = ["172.16.0.0/16"]
      destination_addresses = [
        "10.0.0.0/22",   # Hub
        "10.0.4.0/22",   # AKS Spoke
        "10.0.8.0/23",   # Data & AI Spoke
        "10.0.10.0/24",  # Apps Spoke
        "10.0.11.0/24"   # Shared Services Spoke
      ]
      destination_ports     = ["*"]
    }
  }

  # -----------------------------------------------------------------------
  # F4: Resolución DNS Privada (Management y Spokes hacia Inbound Endpoint de DNS Resolver)
  # Origen: Management Subnet (10.0.0.0/24) y Spokes
  # Destino: snet-hub-dnsin-prod-swe (10.0.3.0/27)
  # -----------------------------------------------------------------------
  network_rule_collection {
    name     = "rc-dns-resolution"
    priority = 240
    action   = "Allow"

    rule {
      name                  = "Allow-Spokes-and-Mngt-to-DNSResolverInbound"
      protocols             = ["UDP", "TCP"]
      source_addresses      = [
        "10.0.0.0/24",   # Hub Management (Hopping Host)
        "10.0.4.0/22",   # AKS Spoke
        "10.0.8.0/23",   # Data & AI Spoke
        "10.0.10.0/24",  # Apps Spoke
        "10.0.11.0/24"   # Shared Services Spoke
      ]
      destination_addresses = ["10.0.3.0/27"]
      destination_ports     = ["53"]
    }
  }

  # -----------------------------------------------------------------------
  # F5: Acceso Específico a Private Endpoints (Segmentado por Spoke según CSV)
  # -----------------------------------------------------------------------
  network_rule_collection {
    name     = "rc-spoke-to-private-endpoints"
    priority = 250
    action   = "Allow"

    # Spoke: AKS -> Shared Services PE (ACR, Key Vault)
    rule {
      name                  = "Allow-AKS-to-SharedPE-HTTPS"
      protocols             = ["TCP"]
      source_addresses      = ["10.0.4.0/23", "10.0.6.0/24"] # Workloads & System
      destination_addresses = ["10.0.11.0/25"]                # snet-shared-pe-prod-swe
      destination_ports     = ["443"]
    }

    # Spoke: AKS -> Apps PE (Cosmos DB, Azure SQL, Service Bus, Event Hub)
    rule {
      name                  = "Allow-AKS-to-AppsPE"
      protocols             = ["TCP"]
      source_addresses      = ["10.0.4.0/23", "10.0.6.0/24"]
      destination_addresses = ["10.0.10.192/26"]              # snet-apps-pe-prod-swe
      destination_ports     = ["443", "1433", "5671"]
    }

    # Spoke: AKS -> Data & AI PE (Storage / Datalake)
    rule {
      name                  = "Allow-AKS-to-DataAIPE"
      protocols             = ["TCP"]
      source_addresses      = ["10.0.4.0/23", "10.0.6.0/24"]
      destination_addresses = ["10.0.8.0/25"]                 # snet-dataai-pe-prod-swe
      destination_ports     = ["443"]
    }

    # Spoke: Apps -> Shared Services PE (APIM, App Config)
    rule {
      name                  = "Allow-Apps-to-SharedPE"
      protocols             = ["TCP"]
      source_addresses      = ["10.0.10.0/25", "10.0.10.128/26"] # ACA & Messaging
      destination_addresses = ["10.0.11.0/25"]                    # snet-shared-pe-prod-swe
      destination_ports     = ["443"]
    }

    # Spoke: Apps -> Apps PE (Azure SQL, Service Bus, Blob Storage)
    rule {
      name                  = "Allow-Apps-to-AppsPE"
      protocols             = ["TCP"]
      source_addresses      = ["10.0.10.0/25", "10.0.10.128/26"]
      destination_addresses = ["10.0.10.192/26"]                  # snet-apps-pe-prod-swe
      destination_ports     = ["443", "1433", "5671"]
    }

    # Spoke: Data-IA -> Data-IA PE (Storage Account, AI Search, OpenAI, Redis)
    rule {
      name                  = "Allow-DataIA-to-DataAIPE"
      protocols             = ["TCP"]
      source_addresses      = [
        "10.0.8.128/25", # snet-dataai-analytics-prod-swe
        "10.0.9.0/25",   # snet-dataai-compute-prod-swe
        "10.0.9.128/26"  # snet-dataai-streaming-prod-swe
      ]
      destination_addresses = ["10.0.8.0/25"] # snet-dataai-pe-prod-swe
      destination_ports     = ["443", "6379"]
    }

    # Spoke: Data-IA -> Shared PE (ACR / DevOps Tools)
    rule {
      name                  = "Allow-DataIA-to-SharedPE"
      protocols             = ["TCP"]
      source_addresses      = ["10.0.8.128/25", "10.0.9.0/25"]
      destination_addresses = ["10.0.11.0/25"] # snet-shared-pe-prod-swe
      destination_ports     = ["443"]
    }
  }

  # -----------------------------------------------------------------------
  # F6: Interacción entre Spokes (East-West estrictamente acotada según CSV)
  # -----------------------------------------------------------------------
  network_rule_collection {
    name     = "rc-spoke-to-spoke-eastwest"
    priority = 260
    action   = "Allow"

    # Static Web Apps / Frontend -> ACA RAG API
    rule {
      name                  = "Allow-Apps-to-DataIA-ACA"
      protocols             = ["TCP"]
      source_addresses      = ["10.0.10.0/25"] # snet-apps-aca-prod-swe
      destination_addresses = ["10.0.9.0/25"]  # snet-dataai-compute-prod-swe
      destination_ports     = ["443"]
    }

    # Azure Functions -> ACA Job (Lanzar indexación)
    rule {
      name                  = "Allow-Functions-to-ACAJob"
      protocols             = ["TCP"]
      source_addresses      = ["10.0.10.0/25"] # snet-apps-aca-prod-swe
      destination_addresses = ["10.0.9.0/25"]  # snet-dataai-compute-prod-swe
      destination_ports     = ["443"]
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

  # -----------------------------------------------------------------------
  # F7: Tráfico Saliente a Internet Autorizado (Repositorios, CI/CD, MCR, Telemetría)
  # -----------------------------------------------------------------------
  application_rule_collection {
    name     = "rc-egress-internet"
    priority = 310
    action   = "Allow"

    # A. Repositorios de Código y CI/CD: Restringido a Cómputo y DevOps Tools
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
      source_addresses = [
        "10.0.0.0/24",    # snet-hub-mngt-prod-swe (Hopping Host)
        "10.0.4.0/23",    # snet-aks-workload-prod-swe (AKS Workloads)
        "10.0.6.0/24",    # snet-aks-system-prod-swe (AKS System)
        "10.0.10.0/25",   # snet-apps-aca-prod-swe (ACA Apps / Functions)
        "10.0.9.0/25",    # snet-dataai-compute-prod-swe (ACA Data/AI)
        "10.0.11.192/27"  # snet-shared-devops-prod-swe (DevOps Tools CI/CD)
      ]
      destination_fqdns = [
        "github.com",
        "*.github.com",
        "*.githubusercontent.com",
        "dev.azure.com",
        "*.dev.azure.com"
      ]
    }

    # B. Acceso a Registros de Contenedores: Restringido a AKS, ACA y CI/CD
    rule {
      name = "Allow-Container-Registries"
      protocols {
        type = "Https"
        port = 443
      }
      protocols {
        type = "Http"
        port = 80
      }
      source_addresses = [
        "10.0.4.0/23",    # snet-aks-workload-prod-swe (AKS Workloads)
        "10.0.6.0/24",    # snet-aks-system-prod-swe (AKS System)
        "10.0.10.0/25",   # snet-apps-aca-prod-swe (ACA Apps)
        "10.0.9.0/25",    # snet-dataai-compute-prod-swe (ACA Data/AI)
        "10.0.11.192/27"  # snet-shared-devops-prod-swe (DevOps Tools CI/CD)
      ]
      destination_fqdns = [
        "*.azurecr.io",
        "*.mcr.microsoft.com",
        "mcr.microsoft.com",
        "docker.io",
        "*.docker.io",
        "production.cloudflare.docker.com"
      ]
    }

    # C. Actualizaciones de SO, Azure Monitor y Telemetría
    rule {
      name = "Allow-OS-Updates-and-AzureMonitor"
      protocols {
        type = "Https"
        port = 443
      }
      protocols {
        type = "Http"
        port = 80
      }
      source_addresses = [
        "10.0.0.0/24",    # snet-hub-mngt-prod-swe (Hopping Host)
        "10.0.4.0/23",    # snet-aks-workload-prod-swe (AKS Workloads)
        "10.0.6.0/24",    # snet-aks-system-prod-swe (AKS System)
        "10.0.7.128/27",  # snet-aks-monitoring-prod-swe (AKS Monitoring)
        "10.0.10.0/25",   # snet-apps-aca-prod-swe (ACA Apps)
        "10.0.8.128/25",  # snet-dataai-analytics-prod-swe (Data Analytics)
        "10.0.9.0/25",    # snet-dataai-compute-prod-swe (ACA Data/AI)
        "10.0.11.192/27"  # snet-shared-devops-prod-swe (DevOps Tools)
      ]
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