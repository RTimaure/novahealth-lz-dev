# Archivo: modules/management_groups/outputs.tf

output "management_group_ids" {
  description = "Mapa con los IDs de todos los Management Groups creados en la jerarquía de NovaHealth."
  value = {
    root           = azurerm_management_group.root.id
    platform       = azurerm_management_group.level_2["platform"].id
    landing_zones  = azurerm_management_group.level_2["landing_zones"].id
    sandbox        = azurerm_management_group.level_2["sandbox"].id
    identity       = azurerm_management_group.level_3["identity"].id
    management     = azurerm_management_group.level_3["management"].id
    connectivity   = azurerm_management_group.level_3["connectivity"].id
    security       = azurerm_management_group.level_3["security"].id
    production     = azurerm_management_group.level_3["production"].id
    non_production = azurerm_management_group.level_3["non_production"].id
  }
}