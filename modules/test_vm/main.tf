# Archivo: modules/test_vm/main.tf

# =========================================================================
# REGLAS SOBRE LA NSG YA EXISTENTE DEL SPOKE (no se crea NSG nueva)
# La NSG destino ya está asociada al subnet en modules/networking/main.tf;
# aquí solo añadimos las reglas puntuales necesarias para el test de ping.
# =========================================================================
resource "azurerm_network_security_rule" "allow_icmp_in" {
  provider                    = azurerm.target
  name                        = "Allow-ICMP-In-TestVM-${var.vm_scope}"
  priority                    = var.icmp_in_priority
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Icmp"
  source_port_range           = "*"
  destination_port_range      = "*"
  source_address_prefix       = var.allow_icmp_from_cidr
  destination_address_prefix  = azurerm_network_interface.vm_nic.private_ip_address
  resource_group_name         = var.existing_nsg_resource_group_name
  network_security_group_name = var.existing_nsg_name
}

resource "azurerm_network_security_rule" "allow_icmp_out" {
  provider                    = azurerm.target
  name                        = "Allow-ICMP-Out-TestVM-${var.vm_scope}"
  priority                    = var.icmp_out_priority
  direction                   = "Outbound"
  access                      = "Allow"
  protocol                    = "Icmp"
  source_port_range           = "*"
  destination_port_range      = "*"
  source_address_prefix       = azurerm_network_interface.vm_nic.private_ip_address
  destination_address_prefix  = var.allow_icmp_from_cidr
  resource_group_name         = var.existing_nsg_resource_group_name
  network_security_group_name = var.existing_nsg_name
}

# =========================================================================
# NETWORK INTERFACE (sin IP pública; sin puerto 22 abierto en ninguna NSG)
# Naming C4 (5 segmentos): nic-<scope>-<environment>-<region>-<nnn>
# Se despliega directamente en el subnet del spoke elegido; hereda
# automáticamente la NSG ya asociada a ese subnet (más las 2 reglas ICMP de arriba).
# Si necesitas entrar al SO, usa Azure Serial Console o Run Command desde el
# portal/CLI (no requieren conectividad de red hacia la VM).
# =========================================================================
resource "azurerm_network_interface" "vm_nic" {
  provider            = azurerm.target
  name                = "nic-${var.vm_scope}-${var.environment}-${var.region_suffix}-${var.instance_number}"
  location            = var.location
  resource_group_name = var.resource_group_name
  tags                = var.tags

  ip_configuration {
    name                          = "ipconfig1"
    subnet_id                     = var.subnet_id
    private_ip_address_allocation = "Dynamic"
  }
}

# =========================================================================
# VIRTUAL MACHINE LINUX (Ubuntu 22.04 LTS) - Autenticación por password.
# El puerto 22 no está abierto en ninguna NSG, por lo que la contraseña no es
# alcanzable por red; solo sirve para acceso vía Serial Console/Run Command.
# Naming C4 (5 segmentos): vm-<scope>-<environment>-<region>-<nnn>
# =========================================================================
resource "azurerm_linux_virtual_machine" "vm" {
  provider            = azurerm.target
  name                = "vm-${var.vm_scope}-${var.environment}-${var.region_suffix}-${var.instance_number}"
  location            = var.location
  resource_group_name = var.resource_group_name
  size                = var.vm_size
  admin_username      = var.admin_username
  network_interface_ids = [
    azurerm_network_interface.vm_nic.id
  ]
  disable_password_authentication = false
  admin_password                   = var.admin_password
  tags                             = var.tags

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "microsoftazurelinux"
    offer     = "azurelinux-4"
    sku       = "4-arm64"
    version   = "latest"
  }
}
