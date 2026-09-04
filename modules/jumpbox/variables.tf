# Archivo: modules/jumpbox/variables.tf

variable "location" {
  description = "Región de despliegue (swedencentral / westeurope)"
  type        = string
}

locals {
  effective_resource_group_name = (
    var.resource_group_name != null ? var.resource_group_name :
    var.location == "swedencentral" ? "rg-mgmtvm-prod-swe" :
    var.location == "westeurope" ? "rg-mgmtvm-prod-weu" :
    null
  )
}

variable "resource_group_name" {
  description = "Nombre del Resource Group destino (ej. rg-mgmtvm-prod-swe)"
  type        = string
  default = null
}

variable "subnet_id" {
  description = "Resource ID de la subred de gestión (snet-hub-mngt-*), típicamente proveniente de módulo networking"
  type        = string
}

variable "environment" {
  description = "Entorno lógico para el naming convention (prod, dr)"
  type        = string
  default     = "prod"
}

variable "region_suffix" {
  description = "Sufijo de región para el naming convention (swe, weu)"
  type        = string
  default     = "swe"
}

variable "vm_size" {
  description = "SKU de la VM. Debe pertenecer a la lista permitida por la Azure Policy 'nh-cost-allowed_vm_skus'"
  type        = string
  default     = "Standard_B2ps_v2"

  validation {
    condition = contains(
      ["Standard_D2s_v5", "Standard_D4s_v5", "Standard_B2ps_v2", "Standard_B4s_v2"],
      var.vm_size
    )
    error_message = "El vm_size debe estar dentro de las SKUs corporativas aprobadas por FinOps (ver nh-cost-allowed_vm_skus)."
  }
}

variable "admin_username" {
  description = "Usuario administrador local de la jumpbox"
  type        = string
  default     = "nh-jumpbox-admin"
}

variable "admin_password" {
  description = "Contraseña del usuario administrador local. Solo se usa para autenticación del SO vía Serial Console/Run Command; el puerto 22 no se abre en la NSG, por lo que no es alcanzable por red."
  type        = string
  sensitive   = true

  validation {
    condition     = length(var.admin_password) >= 12
    error_message = "La contraseña debe tener al menos 12 caracteres (requisito de complejidad de Azure)."
  }
}

variable "os_disk_size_gb" {
  description = "Tamaño del disco de SO en GB"
  type        = number
  default     = 64
}

variable "tags" {
  description = "Etiquetas corporativas de NovaHealth (heredadas del Resource Group)"
  type        = map(string)
  default     = {}
}

# -------------------------------------------------------------------------
# Observabilidad (integración con modules/observability)
# -------------------------------------------------------------------------
variable "enable_monitoring_agent" {
  description = "Habilita el agente OMS/Log Analytics en la jumpbox"
  type        = bool
  default     = true
}

variable "log_analytics_workspace_id" {
  description = "Workspace ID de Log Analytics centralizado (module.observability.log_analytics_workspace_id -> atributo .workspace_id, no el resource ID)"
  type        = string
  default     = null
}

variable "log_analytics_workspace_key" {
  description = "Clave compartida del Log Analytics Workspace centralizado"
  type        = string
  default     = null
  sensitive   = true
}

# -------------------------------------------------------------------------
# FinOps: apagado automático
# -------------------------------------------------------------------------
variable "enable_auto_shutdown" {
  description = "Habilita el auto-apagado diario de la jumpbox (optimización de costes)"
  type        = bool
  default     = true
}

variable "auto_shutdown_time" {
  description = "Hora de apagado automático en formato HHMM (hora local)"
  type        = string
  default     = "1900"
}

variable "auto_shutdown_timezone" {
  description = "Zona horaria del apagado automático"
  type        = string
  default     = "W. Europe Standard Time"
}

variable "notification_email" {
  description = "Email para notificación previa al auto-apagado"
  type        = string
  default     = "ops-alerts@novahealth.com"
}