# Archivo: modules/policy/variables.tf

variable "root_mg_id" {
  description = "ID del Management Group raíz"
  type        = string
}

variable "platform_mg_id" {
  description = "ID del Management Group Platform"
  type        = string
  default     = null
}

variable "landing_zones_mg_id" {
  description = "ID del Management Group Landing Zones"
  type        = string
  default     = null
}

variable "management_group_ids" {
  description = "Mapa completo de IDs de Management Groups"
  type        = map(string)
  default     = {}
}

variable "target_subscriptions" {
  description = "Mapa de suscripciones objetivo"
  type        = map(string)
  default     = {}
}

variable "allowed_locations" {
  description = "Lista de regiones permitidas por Azure Policy"
  type        = list(string)
  default     = ["swedencentral", "westeurope"]
}

variable "allowed_resource_types" {
  description = "Lista de tipos de recursos permitidos en la Landing Zone (Allowed Resource Types - Built-in Policy)"
  type        = list(string)
  default = [
    "Microsoft.Resources/resourceGroups",
    "Microsoft.Resources/deployments",
    "Microsoft.Resources/tags",
    "Microsoft.Network/virtualNetworks",
    "Microsoft.Network/virtualNetworks/subnets",
    "Microsoft.Network/virtualNetworks/virtualNetworkPeerings",
    "Microsoft.Network/networkSecurityGroups",
    "Microsoft.Network/networkSecurityGroups/securityRules",
    "Microsoft.Network/routeTables",
    "Microsoft.Network/routeTables/routes",
    "Microsoft.Network/publicIPAddresses",
    "Microsoft.Network/networkInterfaces",
    "Microsoft.Network/azureFirewalls",
    "Microsoft.Network/firewallPolicies",
    "Microsoft.Network/firewallPolicies/ruleCollectionGroups",
    "Microsoft.Network/bastionHosts",
    "Microsoft.Network/virtualNetworkGateways",
    "Microsoft.Network/applicationGateways",
    "Microsoft.Network/applicationGatewayWebApplicationFirewallPolicies",
    "Microsoft.Network/privateEndpoints",
    "Microsoft.Network/privateDnsZones",
    "Microsoft.Network/privateDnsZones/virtualNetworkLinks",
    "Microsoft.Network/privateDnsZones/A",
    "Microsoft.Network/dnsResolvers",
    "Microsoft.Network/dnsResolvers/inboundEndpoints",
    "Microsoft.Network/dnsResolvers/outboundEndpoints",
    "Microsoft.Compute/virtualMachines",
    "Microsoft.Compute/virtualMachines/extensions",
    "Microsoft.Compute/disks",
    "Microsoft.Storage/storageAccounts",
    "Microsoft.KeyVault/vaults",
    "Microsoft.KeyVault/vaults/secrets",
    "Microsoft.KeyVault/vaults/keys",
    "Microsoft.OperationalInsights/workspaces",
    "Microsoft.OperationsManagement/solutions",
    "microsoft.insights/components",
    "microsoft.insights/actionGroups",
    "microsoft.insights/activityLogAlerts",
    "microsoft.insights/metricAlerts",
    "microsoft.insights/workbooks",
    "Microsoft.ContainerService/managedClusters",
    "Microsoft.ContainerRegistry/registries",
    "Microsoft.App/containerApps",
    "Microsoft.App/managedEnvironments",
    "Microsoft.CognitiveServices/accounts",
    "Microsoft.Search/searchServices",
    "Microsoft.Sql/servers",
    "Microsoft.Sql/servers/databases",
    "Microsoft.DocumentDB/databaseAccounts",
    "Microsoft.ServiceBus/namespaces",
    "Microsoft.EventGrid/topics",
    "Microsoft.EventGrid/eventSubscriptions",
    "Microsoft.EventHub/namespaces",
    "Microsoft.Web/sites",
    "Microsoft.Web/serverfarms",
    "Microsoft.Web/staticSites",
    "Microsoft.Cache/Redis",
    "Microsoft.CostManagement/budgets",
    "Microsoft.Consumption/budgets",
    "Microsoft.Authorization/policyAssignments",
    "Microsoft.Authorization/roleAssignments",
    "Microsoft.Authorization/locks",
    "Microsoft.DevTestLab/schedules"
  ]
}