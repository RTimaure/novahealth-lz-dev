# Archivo: modules/management_groups/outputs.tf

output "management_group_ids" {
  description = "Mapa con los IDs de todos los Management Groups creados en la jerarquía de NovaHealth."
  value = merge(
    {
      root = azurerm_management_group.root.id
    },
    {
      for k, v in azurerm_management_group.level_2 : k => v.id
    },
    {
      for k, v in azurerm_management_group.level_3 : k => v.id
    }
  )
}