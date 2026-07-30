# Archivo: modules/rbac/outputs.tf

output "entra_group_ids" {
  description = "Mapa con los Object IDs de los grupos de Azure Entra ID creados para NovaHealth."
  value = {
    for k, v in azuread_group.novahealth_groups : k => v.object_id
  }
}

output "custom_role_definition_ids" {
  description = "Mapa con los IDs de los roles personalizados creados en Azure."
  value = {
    for k, v in azurerm_role_definition.custom_roles : k => v.role_definition_resource_id
  }
}

output "role_assignment_ids" {
  description = "Mapa de todos los IDs de asignaciones de rol generadas en MGs y Suscripciones."
  value = merge(
    { for k, v in azurerm_role_assignment.mg_rbac : k => v.id },
    { for k, v in azurerm_role_assignment.sub_rbac : k => v.id },
    { for k, v in azurerm_role_assignment.cicd_rbac : k => v.id }
  )
}