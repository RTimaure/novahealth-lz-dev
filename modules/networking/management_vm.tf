# Archivo: modules/networking/management_vm.tf

# =========================================================================
# MANAGEMENT NETWORK INTERFACE (VM DESHABILITADA TEMPORALMENTE)
# =========================================================================

# -------------------------------------------------------------------------
# 1. NETWORK INTERFACE (SIN IP PÚBLICA)
# Cluster C4 (5 segmentos): nic-<scope>-<env>-<region>-<nnn>
# Ejemplo: nic-mngt-prod-swe-001
# -------------------------------------------------------------------------
resource "azurerm_network_interface" "mngt_vm_nic" {
  provider            = azurerm.connectivity
  name                = "nic-mngt-prod-swe-001"
  location            = var.location
  resource_group_name = lookup(var.resource_group_names, "rg-nethub-prod-swe", "rg-nethub-prod-swe")
  tags                = lookup(var.resource_group_tags, "rg-mgmtvm-prod-swe", var.tags)

  ip_configuration {
    name                          = "ipconfig1"
    subnet_id                     = azurerm_subnet.hub_prod["hub_prod_snet-hub-mngt-prod-swe"].id
    private_ip_address_allocation = "Dynamic"
  }
}