# Archivo: outputs.tf

# Salidas de la jerarquía
output "management_group_ids" {
  description = "IDs de los Management Groups creados."
  value       = module.management_groups.management_group_ids
}

# Salidas de Gobernanza Financiera
output "finops_budgets" {
  description = "Resumen de los presupuestos configurados."
  value       = module.finops.finops_summary
}

# Salidas de Seguridad
output "custom_policy_definition_ids" {
  description = "IDs de las definiciones de políticas personalizadas creadas."
  value       = module.policy.custom_policy_definition_ids
}

# Salidas de Identidad / Acceso
output "rbac_group_ids" {
  description = "IDs de los grupos de Azure Entra ID creados."
  value       = module.rbac.entra_group_ids
}