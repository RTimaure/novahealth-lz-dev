# Archivo: modules/jumpbox/main.tf

terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
  }
}

locals {
  # Naming Cluster C4 (5 segmentos): <prefix>-<scope>-<environment>-<region>-<nnn>
  nic_name = "nic-mngt-${var.environment}-${var.region_suffix}-001"
  vm_name  = "vm-mngt-${var.environment}-${var.region_suffix}-001"
}

# -------------------------------------------------------------------------
# 1. NETWORK INTERFACE (sin IP pública - acceso exclusivo vía Azure Bastion)
# -------------------------------------------------------------------------
resource "azurerm_network_interface" "jumpbox" {
  name                = local.nic_name
  location            = var.location
  resource_group_name = var.resource_group_name
  tags                = var.tags

  ip_configuration {
    name                          = "ipconfig1"
    subnet_id                     = var.subnet_id
    private_ip_address_allocation = "Dynamic"
  }
}

# -------------------------------------------------------------------------
# 2. VIRTUAL MACHINE (Ubuntu 22.04 LTS, Managed Identity)
# -------------------------------------------------------------------------
resource "azurerm_linux_virtual_machine" "jumpbox" {
  name                = local.vm_name
  location            = var.location
  resource_group_name = var.resource_group_name
  size                = var.vm_size
  admin_username      = var.admin_username
  tags                = var.tags

  network_interface_ids = [
    azurerm_network_interface.jumpbox.id
  ]

  disable_password_authentication = false
  admin_password                   = var.admin_password


  os_disk {
    name                 = "osdisk-jumpbox-${var.environment}-${var.region_suffix}-001"
    caching              = "ReadWrite"
    storage_account_type = "StandardSSD_LRS"
    disk_size_gb         = var.os_disk_size_gb
  }

  source_image_reference {
    publisher = "microsoftazurelinux"
    offer     = "azurelinux-4"
    sku       = "4-arm64"
    version   = "latest"
  }

  # Managed Identity para futura integración RBAC (ej. lectura de Key Vault, Storage)
  identity {
    type = "SystemAssigned"
  }

  boot_diagnostics {
    storage_account_uri = null # Managed storage account (gestionado por Azure)
  }
}

# -------------------------------------------------------------------------
# 3. FINOPS: AUTO-APAGADO DIARIO (evita coste 24/7 de un recurso de uso puntual)
# -------------------------------------------------------------------------
resource "azurerm_dev_test_global_vm_shutdown_schedule" "jumpbox" {
  count = var.enable_auto_shutdown ? 1 : 0

  virtual_machine_id = azurerm_linux_virtual_machine.jumpbox.id
  location            = var.location
  enabled             = true

  daily_recurrence_time = var.auto_shutdown_time
  timezone               = var.auto_shutdown_timezone

  notification_settings {
    enabled         = true
    time_in_minutes = 30
    email           = var.notification_email
  }
}