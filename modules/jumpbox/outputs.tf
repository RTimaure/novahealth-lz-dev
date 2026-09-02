# Archivo: modules/jumpbox/outputs.tf

output "vm_id" {
  description = "Resource ID de la VM jumpbox"
  value       = azurerm_linux_virtual_machine.jumpbox.id
}

output "vm_name" {
  value = azurerm_linux_virtual_machine.jumpbox.name
}

output "private_ip_address" {
  description = "IP privada de la jumpbox dentro de snet-hub-mngt"
  value       = azurerm_network_interface.jumpbox.private_ip_address
}

output "principal_id" {
  description = "Object ID de la Managed Identity de la jumpbox (para asignaciones RBAC futuras)"
  value       = azurerm_linux_virtual_machine.jumpbox.identity[0].principal_id
}

output "nic_id" {
  value = azurerm_network_interface.jumpbox.id
}