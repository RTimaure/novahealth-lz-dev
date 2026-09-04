# Archivo: modules/test_vm/outputs.tf

output "vm_id" {
  description = "ID de la máquina virtual desplegada."
  value       = azurerm_linux_virtual_machine.vm.id
}

output "vm_name" {
  description = "Nombre de la máquina virtual desplegada."
  value       = azurerm_linux_virtual_machine.vm.name
}

output "private_ip_address" {
  description = "IP privada asignada a la VM (usar como destino/origen en las pruebas de ping)."
  value       = azurerm_network_interface.vm_nic.private_ip_address
}

output "applied_nsg_name" {
  description = "Nombre de la NSG existente sobre la que se añadieron las reglas ICMP/SSH."
  value       = var.existing_nsg_name
}
