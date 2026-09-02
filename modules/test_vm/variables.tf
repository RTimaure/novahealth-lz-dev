# Archivo: modules/test_vm/variables.tf

terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
      configuration_aliases = [azurerm.target]
    }
  }
}

variable "location" {
  description = "Región de despliegue (debe coincidir con la del subnet_id indicado)."
  type        = string
}

variable "resource_group_name" {
  description = "Nombre del Resource Group donde se desplegará la VM."
  type        = string
}

variable "subnet_id" {
  description = "ID completo del subnet destino del spoke elegido."
  type        = string
}

# =========================================================================
# NSG YA EXISTENTE (no se crea ninguna NSG nueva; se reutiliza la del spoke)
# =========================================================================
variable "existing_nsg_name" {
  description = "Nombre de la NSG ya asociada al subnet destino (obtenida de module.networking.nsgs[<key>].name)."
  type        = string
}

variable "existing_nsg_resource_group_name" {
  description = "Resource Group de la NSG ya existente (obtenida de module.networking.nsgs[<key>].resource_group_name)."
  type        = string
}

variable "icmp_in_priority" {
  description = "Prioridad para la regla de entrada ICMP. Debe ser un valor libre en la NSG destino (revisa modules/networking/nsg_rules.tf antes de fijar el valor)."
  type        = number
  default     = 900
}

variable "icmp_out_priority" {
  description = "Prioridad para la regla de salida ICMP."
  type        = number
  default     = 900
}

variable "vm_scope" {
  description = "Identificador corto del propósito de la VM para la nomenclatura corporativa C4 (ej. 'test', 'mngt')."
  type        = string
  default     = "test"
}

variable "environment" {
  description = "Entorno lógico: prod o nprod, usado en el naming."
  type        = string
  default     = "prod"
}

variable "region_suffix" {
  description = "Sufijo de región para naming (swe = SwedenCentral, weu = WestEurope)."
  type        = string
  default     = "swe"
}

variable "instance_number" {
  description = "Número de instancia (segmento nnn de la convención C4)."
  type        = string
  default     = "001"
}

variable "vm_size" {
  description = "SKU de VM. Debe pertenecer a la lista de SKUs permitidos por Azure Policy (nh-cost-allowed_vm_skus)."
  type        = string
  default     = "Standard_B2ps_v2"

  validation {
    condition = contains(
      ["Standard_D2s_v5", "Standard_D4s_v5", "Standard_B2s_v2", "Standard_B4s_v2", "Standard_B2ps_v2"],
      var.vm_size
    )
    error_message = "El SKU debe ser uno de los aprobados por la política de costes de NovaHealth."
  }
}

variable "admin_username" {
  description = "Usuario administrador local de la VM."
  type        = string
  default     = "azadmin"
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

variable "allow_icmp_from_cidr" {
  description = "CIDR origen autorizado para ICMP (por defecto, ManagementSubnet del Hub prod)."
  type        = string
  default     = "10.0.0.0/24"
}

variable "tags" {
  description = "Etiquetas corporativas NovaHealth (8 campos obligatorios)."
  type        = map(string)
  default     = {}
}
