# Archivo: modules/networking/management_vm.tf

# =========================================================================
# MANAGEMENT NETWORK INTERFACE (VM DESHABILITADA TEMPORALMENTE)
# =========================================================================

# -------------------------------------------------------------------------
# 1. NETWORK INTERFACE (SIN IP PÚBLICA)
# -------------------------------------------------------------------------
resource "azurerm_network_interface" "mngt_vm_nic" {
  provider            = azurerm.connectivity
  name                = "nic-mngt-prod-swe-001"
  location            = var.location
  resource_group_name = lookup(var.resource_group_names, "rg-mngt-prod-swe", "rg-mngt-prod-swe")
  tags                = var.tags

  ip_configuration {
    name                          = "ipconfig1"
    subnet_id                     = azurerm_subnet.hub_prod["hub_prod_snet-mngt-prod-swe-001"].id
    private_ip_address_allocation = "Dynamic"
  }
}

