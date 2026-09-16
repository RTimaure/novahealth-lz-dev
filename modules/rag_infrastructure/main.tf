# Archivo: modules/rag_infrastructure/main.tf
#
# Implementación concreta de la arquitectura RAG (Retrieval-Augmented
# Generation) para NovaHealth, siguiendo:
#   - "Arquitectura RAG v2.4"            -> diseño funcional, guardrails, RBAC
#   - "Documentación Técnica RAG demo_prod" -> opción PRODUCCIÓN Zero-Trust
#
# Patrón general:
#   Ingesta:  Blob Storage --(BlobCreated/Deleted)--> Event Grid --> Storage
#             Queue --(KEDA)--> ACA Job (extrae, chunkea, embebe, indexa)
#   Consulta: ACA API (interna) -> Redis (caché) -> Azure AI Search (híbrido)
#             -> Azure OpenAI (GPT-4o mini) -> respuesta con guardrails
#
# Todo el tráfico de datos hacia PaaS se realiza vía Private Endpoints sobre
# las zonas DNS privadas ya creadas por modules/networking, y la
# autenticación entre servicios usa exclusivamente Managed Identities
# (principio de mínimo privilegio, sin secretos estáticos en el código de
# aplicación).

locals {
  name_suffix = "${var.environment_name}-${var.region_suffix}"

  common_tags = merge(var.tags, {
    workload = "chatbot-rag"
    module   = "rag_infrastructure"
  })

  # Definición del índice de Azure AI Search, alineada con la tabla de
  # metadatos y el diseño de índice descritos en "Arquitectura RAG v2.4" §8-9.
  # Se aplica vía REST (null_resource + az rest) porque azurerm no gestiona
  # el esquema de índices de Azure AI Search como recurso nativo.
  search_index_definition = {
    name = var.search_index_name
    fields = [
      { name = "chunk_id", type = "Edm.String", key = true, filterable = true },
      { name = "document_id", type = "Edm.String", filterable = true, facetable = true },
      { name = "document_name", type = "Edm.String", searchable = true, filterable = true },
      { name = "document_type", type = "Edm.String", filterable = true, facetable = true },
      { name = "category", type = "Edm.String", filterable = true, facetable = true },
      { name = "document_owner", type = "Edm.String", filterable = true, facetable = true },
      { name = "version", type = "Edm.String", filterable = true },
      { name = "environment", type = "Edm.String", filterable = true, facetable = true },
      { name = "source_path", type = "Edm.String" },
      { name = "created_date", type = "Edm.DateTimeOffset", filterable = true, sortable = true },
      { name = "updated_date", type = "Edm.DateTimeOffset", filterable = true, sortable = true },
      { name = "tags", type = "Collection(Edm.String)", filterable = true, facetable = true },
      { name = "chunk_index", type = "Edm.Int32", filterable = true, sortable = true },
      { name = "chunk_type", type = "Edm.String", filterable = true, facetable = true },
      { name = "content", type = "Edm.String", searchable = true },
      {
        name                = "content_vector"
        type                = "Collection(Edm.Single)"
        searchable          = true
        dimensions          = 1536 # text-embedding-3-small
        vectorSearchProfile = "rag-vector-profile"
      },
      { name = "classification", type = "Edm.String", filterable = true, facetable = true },
      { name = "compliance_domain", type = "Edm.String", filterable = true, facetable = true },
    ]
    vectorSearch = {
      algorithms = [
        { name = "rag-hnsw", kind = "hnsw" }
      ]
      profiles = [
        { name = "rag-vector-profile", algorithm = "rag-hnsw" }
      ]
    }
    semantic = {
      configurations = [
        {
          name = "rag-semantic-config"
          prioritizedFields = {
            titleField = { fieldName = "document_name" }
            prioritizedContentFields = [
              { fieldName = "content" }
            ]
            prioritizedKeywordsFields = [
              { fieldName = "tags" }
            ]
          }
        }
      ]
    }
  }
}

# ===========================================================================
# 1. IDENTIDADES ADMINISTRADAS (UAMI) — §13 Gestión de Identidades
# ===========================================================================

resource "azurerm_user_assigned_identity" "rag_api" {
  name                = "uami-rag-api-${local.name_suffix}-01"
  location            = var.location
  resource_group_name = var.resource_group_name
  tags                = local.common_tags
}

resource "azurerm_user_assigned_identity" "rag_ingestion" {
  name                = "uami-rag-ingestion-${local.name_suffix}-01"
  location            = var.location
  resource_group_name = var.resource_group_name
  tags                = local.common_tags
}

# ===========================================================================
# 2. ALMACENAMIENTO DOCUMENTAL Y COLA DE EVENTOS
# ===========================================================================

resource "azurerm_storage_account" "documents" {
  name                     = var.storage_account_name
  resource_group_name      = var.resource_group_name
  location                 = var.location
  account_tier             = "Standard"
  account_replication_type = var.storage_account_replication_type

  # Zero-Trust: sin acceso público, solo vía Private Endpoint.
  public_network_access_enabled = false
  access_tier                   = "Cool" # FinOps: acceso poco frecuente al corpus documental

  tags = local.common_tags
}

resource "azurerm_storage_container" "documents" {
  name                  = var.documents_container_name
  storage_account_name  = azurerm_storage_account.documents.name
  container_access_type = "private"
}

resource "azurerm_storage_queue" "document_events" {
  name                 = "rag-document-events"
  storage_account_name = azurerm_storage_account.documents.name
}

resource "azurerm_eventgrid_system_topic" "storage_topic" {
  name                   = "evgt-rag-storage-${local.name_suffix}"
  resource_group_name    = var.resource_group_name
  location               = var.location
  source_arm_resource_id = azurerm_storage_account.documents.id
  topic_type             = "Microsoft.Storage.StorageAccounts"
  tags                   = local.common_tags
}

resource "azurerm_eventgrid_system_topic_event_subscription" "queue_sub" {
  name                = "sub-rag-events-to-queue"
  system_topic        = azurerm_eventgrid_system_topic.storage_topic.name
  resource_group_name = var.resource_group_name

  included_event_types = [
    "Microsoft.Storage.BlobCreated",
    "Microsoft.Storage.BlobDeleted",
  ]

  storage_queue_endpoint {
    storage_account_id = azurerm_storage_account.documents.id
    queue_name         = azurerm_storage_queue.document_events.name
  }

  retry_policy {
    max_delivery_attempts = 30
    event_time_to_live    = 1440
  }
}

# ===========================================================================
# 3. AZURE AI SEARCH — Motor de recuperación híbrida (§9)
# ===========================================================================

resource "azurerm_search_service" "rag" {
  name                = var.search_service_name
  resource_group_name = var.resource_group_name
  location            = var.location
  sku                 = var.search_sku

  replica_count       = var.search_replica_count
  partition_count     = var.search_partition_count
  semantic_search_sku = "standard" # Requerido para Semantic Ranking (§3, §9)

  public_network_access_enabled = false
  local_authentication_enabled  = true # Necesario para el bootstrap del índice vía REST (ver null_resource abajo)

  identity {
    type = "SystemAssigned"
  }

  tags = local.common_tags
}

# Bootstrap del esquema de índice. Azure AI Search no expone el índice como
# recurso nativo de azurerm; se crea/actualiza vía REST con la clave admin
# del servicio, solo durante el aprovisionamiento (no se usa en runtime: la
# API y el Job de ingestión acceden en runtime mediante Managed Identity).
resource "null_resource" "search_index" {
  triggers = {
    index_definition_hash = sha256(jsonencode(local.search_index_definition))
    search_service        = azurerm_search_service.rag.name
  }

  provisioner "local-exec" {
    command = <<-EOT
      set -euo pipefail
      cat > /tmp/${var.search_index_name}.json <<'JSON'
      ${jsonencode(local.search_index_definition)}
      JSON
      curl -sf -X PUT \
        "https://${azurerm_search_service.rag.name}.search.windows.net/indexes/${var.search_index_name}?api-version=2024-07-01" \
        -H "api-key: ${azurerm_search_service.rag.primary_key}" \
        -H "Content-Type: application/json" \
        --data-binary @/tmp/${var.search_index_name}.json
    EOT
  }

  depends_on = [azurerm_search_service.rag]
}

# ===========================================================================
# 4. AZURE OPENAI — Embeddings + Generación (§7, §11)
# ===========================================================================

resource "azurerm_cognitive_account" "openai" {
  name                = var.openai_account_name
  resource_group_name = var.resource_group_name
  location            = var.location
  kind                = "OpenAI"
  sku_name            = var.openai_sku_name

  public_network_access_enabled = false
  custom_subdomain_name         = var.openai_account_name

  identity {
    type = "SystemAssigned"
  }

  tags = local.common_tags
}

resource "azurerm_cognitive_deployment" "embedding" {
  name                 = var.embedding_deployment_name
  cognitive_account_id = azurerm_cognitive_account.openai.id

  model {
    format  = "OpenAI"
    name    = "text-embedding-3-small"
    version = var.embedding_model_version
  }

  scale {
    type     = "GlobalStandard" #Cambio hecho por Rebeca antes era Standard
    capacity = var.embedding_capacity
  }
}

resource "azurerm_cognitive_deployment" "chat" {
  name                 = var.chat_deployment_name
  cognitive_account_id = azurerm_cognitive_account.openai.id

  model {
    format  = "OpenAI"
    name    = "gpt-4o-mini"
    version = var.chat_model_version
  }

  scale {
    type     = "GlobalStandard" #Cambio hecho por Rebeca antes era Standard
    capacity = var.chat_capacity
  }
}

# ===========================================================================
# 5. CACHÉ SEMÁNTICA (REDIS) — §3 Flujo de Consulta
# ===========================================================================

resource "azurerm_redis_cache" "rag_cache" {
  name                = "redis-rag-${local.name_suffix}"
  resource_group_name = var.resource_group_name
  location            = var.location

  capacity = var.redis_capacity
  family   = var.redis_family
  sku_name = var.redis_sku_name

  enable_non_ssl_port           = false
  minimum_tls_version           = "1.2"
  public_network_access_enabled = false

  tags = local.common_tags
}

# ===========================================================================
# 6. AZURE CONTAINER REGISTRY — Imágenes de rag-api / rag-ingestion
# ===========================================================================
# Registro privado (SKU Premium requerido para Private Endpoint) donde
# novahealth-apps (repo hermano) publica las imágenes vía su propio CI
# (build-and-push.yml, autenticación OIDC). ACA extrae las imágenes usando
# la misma Managed Identity de cada componente (rol AcrPull, ver sección
# RBAC), sin admin user ni credenciales estáticas.
resource "azurerm_container_registry" "rag" {
  count = var.create_container_registry ? 1 : 0

  name                          = var.container_registry_name
  location                      = var.location
  resource_group_name           = var.resource_group_name
  sku                           = var.container_registry_sku
  admin_enabled                 = false
  public_network_access_enabled = false

  tags = local.common_tags
}

# ===========================================================================
# 7. PRIVATE ENDPOINTS — Zero-Trust networking (§12, §15)
# ===========================================================================

resource "azurerm_private_endpoint" "storage_blob" {
  name                = "pe-rag-blob-${local.name_suffix}"
  location            = var.location
  resource_group_name = var.resource_group_name
  subnet_id           = var.private_endpoint_subnet_id
  tags                = local.common_tags

  private_service_connection {
    name                           = "psc-rag-blob"
    private_connection_resource_id = azurerm_storage_account.documents.id
    is_manual_connection           = false
    subresource_names              = ["blob"]
  }

  private_dns_zone_group {
    name                 = "default"
    private_dns_zone_ids = [var.private_dns_zone_ids["privatelink.blob.core.windows.net"]]
  }
}

resource "azurerm_private_endpoint" "search" {
  name                = "pe-rag-search-${local.name_suffix}"
  location            = var.location
  resource_group_name = var.resource_group_name
  subnet_id           = var.private_endpoint_subnet_id
  tags                = local.common_tags

  private_service_connection {
    name                           = "psc-rag-search"
    private_connection_resource_id = azurerm_search_service.rag.id
    is_manual_connection           = false
    subresource_names              = ["searchService"]
  }

  private_dns_zone_group {
    name                 = "default"
    private_dns_zone_ids = [var.private_dns_zone_ids["privatelink.search.windows.net"]]
  }
}

resource "azurerm_private_endpoint" "openai" {
  name                = "pe-rag-openai-${local.name_suffix}"
  location            = var.location
  resource_group_name = var.resource_group_name
  subnet_id           = var.private_endpoint_subnet_id
  tags                = local.common_tags

  private_service_connection {
    name                           = "psc-rag-openai"
    private_connection_resource_id = azurerm_cognitive_account.openai.id
    is_manual_connection           = false
    subresource_names              = ["account"]
  }

  private_dns_zone_group {
    name                 = "default"
    private_dns_zone_ids = [var.private_dns_zone_ids["privatelink.openai.azure.com"]]
  }
}

resource "azurerm_private_endpoint" "redis" {
  name                = "pe-rag-redis-${local.name_suffix}"
  location            = var.location
  resource_group_name = var.resource_group_name
  subnet_id           = var.private_endpoint_subnet_id
  tags                = local.common_tags

  private_service_connection {
    name                           = "psc-rag-redis"
    private_connection_resource_id = azurerm_redis_cache.rag_cache.id
    is_manual_connection           = false
    subresource_names              = ["redisCache"]
  }

  private_dns_zone_group {
    name                 = "default"
    private_dns_zone_ids = [var.private_dns_zone_ids["privatelink.redis.cache.windows.net"]]
  }
}

resource "azurerm_private_endpoint" "acr" {
  count = var.create_container_registry ? 1 : 0

  name                = "pe-rag-acr-${local.name_suffix}"
  location            = var.location
  resource_group_name = var.resource_group_name
  subnet_id           = var.private_endpoint_subnet_id
  tags                = local.common_tags

  private_service_connection {
    name                           = "psc-rag-acr"
    private_connection_resource_id = azurerm_container_registry.rag[0].id
    is_manual_connection           = false
    subresource_names              = ["registry"]
  }

  private_dns_zone_group {
    name                 = "default"
    private_dns_zone_ids = [var.private_dns_zone_ids["privatelink.azurecr.io"]]
  }
}

# ===========================================================================
# 8. AZURE CONTAINER APPS ENVIRONMENT — modo interno (§12, §16)
# ===========================================================================

resource "azurerm_container_app_environment" "rag" {
  name                           = var.container_app_environment_name
  location                       = var.location
  resource_group_name            = var.resource_group_name
  infrastructure_subnet_id       = var.aca_infrastructure_subnet_id
  internal_load_balancer_enabled = true # Sin IP pública (§12)

  log_analytics_workspace_id = var.log_analytics_workspace_id

  tags = local.common_tags
}

# ===========================================================================
# 9. API RAG (Container App) — Flujo de consulta (§3)
# ===========================================================================

resource "azurerm_container_app" "rag_api" {
  name                         = var.rag_api_name
  resource_group_name          = var.resource_group_name
  container_app_environment_id = azurerm_container_app_environment.rag.id
  revision_mode                = "Single"
  tags                         = local.common_tags

  identity {
    type         = "UserAssigned"
    identity_ids = [azurerm_user_assigned_identity.rag_api.id]
  }

  dynamic "registry" {
    for_each = var.create_container_registry ? [1] : []
    content {
      server   = azurerm_container_registry.rag[0].login_server
      identity = azurerm_user_assigned_identity.rag_api.id
    }
  }

  ingress {
    external_enabled = false # Solo accesible dentro de la VNet / vía Portal Web integrado
    target_port      = 8080
    transport        = "auto"

    traffic_weight {
      latest_revision = true
      percentage      = 100
    }
  }

  template {
    min_replicas = var.rag_api_min_replicas
    max_replicas = var.rag_api_max_replicas

    container {
      name   = "rag-api"
      image  = var.rag_api_image
      cpu    = var.rag_api_cpu
      memory = var.rag_api_memory

      env {
        name  = "AZURE_SEARCH_ENDPOINT"
        value = "https://${azurerm_search_service.rag.name}.search.windows.net"
      }
      env {
        name  = "AZURE_SEARCH_INDEX_NAME"
        value = var.search_index_name
      }
      env {
        name  = "AZURE_OPENAI_ENDPOINT"
        value = azurerm_cognitive_account.openai.endpoint
      }
      env {
        name  = "AZURE_OPENAI_CHAT_DEPLOYMENT"
        value = azurerm_cognitive_deployment.chat.name
      }
      env {
        name  = "AZURE_OPENAI_EMBEDDING_DEPLOYMENT"
        value = azurerm_cognitive_deployment.embedding.name
      }
      env {
        name  = "REDIS_HOSTNAME"
        value = azurerm_redis_cache.rag_cache.hostname
      }
      env {
        name  = "MAX_OUTPUT_TOKENS"
        value = tostring(var.max_output_tokens)
      }
      env {
        name  = "TOP_K"
        value = "5" # §3 Flujo de Consulta: Top-K = 5 (mínimo 3)
      }
      env {
        name  = "AZURE_CLIENT_ID" # Fuerza el uso de la UAMI asignada (evita ambigüedad con System Assigned)
        value = azurerm_user_assigned_identity.rag_api.client_id
      }
      env {
        name  = "APPLICATIONINSIGHTS_CONNECTION_STRING"
        value = var.application_insights_connection_string
      }
    }
  }
}

# ===========================================================================
# 10. ACA JOB DE INGESTIÓN — Flujo de ingesta event-driven (§4, §10, §16)
# ===========================================================================

resource "azurerm_container_app_job" "ingestion" {
  name                         = var.ingestion_job_name
  location                     = var.location
  resource_group_name          = var.resource_group_name
  container_app_environment_id = azurerm_container_app_environment.rag.id
  replica_timeout_in_seconds   = var.ingestion_job_replica_timeout_seconds
  tags                         = local.common_tags

  identity {
    type         = "UserAssigned"
    identity_ids = [azurerm_user_assigned_identity.rag_ingestion.id]
  }

  dynamic "registry" {
    for_each = var.create_container_registry ? [1] : []
    content {
      server   = azurerm_container_registry.rag[0].login_server
      identity = azurerm_user_assigned_identity.rag_ingestion.id
    }
  }

  event_trigger_config {
    parallelism              = 1
    replica_completion_count = 1

    scale {
      min_executions              = var.ingestion_job_min_execution_count
      max_executions              = var.ingestion_job_max_execution_count
      polling_interval_in_seconds = var.ingestion_job_polling_interval_seconds

      rules {
        name             = "azure-queue-rule"
        custom_rule_type = "azure-queue"

        metadata = {
          queueName   = azurerm_storage_queue.document_events.name
          queueLength = "1"
          accountName = azurerm_storage_account.documents.name
        }

        # NOTA (deuda técnica documentada): el disparador KEDA azure-queue en
        # ACA Jobs solo admite autenticación basada en secreto (connection
        # string) en la versión actual de azurerm/KEDA; no soporta todavía
        # Managed Identity para el propio trigger de escalado. Se usa un
        # secreto exclusivamente para esta evaluación de longitud de cola;
        # TODA la lógica de negocio (lectura de blobs, escritura en el
        # índice, llamadas a OpenAI) se realiza en runtime vía Managed
        # Identity (ver rol "Storage Queue Data Message Processor" y
        # asignaciones RBAC más abajo), nunca con esta cadena de conexión.
        authentication {
          secret_name       = "queue-connection-string"
          trigger_parameter = "connection"
        }
      }
    }
  }

  secret {
    name  = "queue-connection-string"
    value = azurerm_storage_account.documents.primary_connection_string
  }

  template {
    container {
      name   = "rag-ingestion"
      image  = var.ingestion_job_image
      cpu    = var.ingestion_job_cpu
      memory = var.ingestion_job_memory

      env {
        name  = "QUEUE_NAME"
        value = azurerm_storage_queue.document_events.name
      }
      env {
        name  = "STORAGE_ACCOUNT_NAME"
        value = azurerm_storage_account.documents.name
      }
      env {
        name  = "DOCUMENTS_CONTAINER"
        value = azurerm_storage_container.documents.name
      }
      env {
        name  = "AZURE_SEARCH_ENDPOINT"
        value = "https://${azurerm_search_service.rag.name}.search.windows.net"
      }
      env {
        name  = "AZURE_SEARCH_INDEX_NAME"
        value = var.search_index_name
      }
      env {
        name  = "AZURE_OPENAI_ENDPOINT"
        value = azurerm_cognitive_account.openai.endpoint
      }
      env {
        name  = "AZURE_OPENAI_EMBEDDING_DEPLOYMENT"
        value = azurerm_cognitive_deployment.embedding.name
      }
      env {
        name  = "AZURE_CLIENT_ID"
        value = azurerm_user_assigned_identity.rag_ingestion.client_id
      }
      env {
        name  = "APPLICATIONINSIGHTS_CONNECTION_STRING"
        value = var.application_insights_connection_string
      }
    }
  }
}

# ===========================================================================
# 11. RBAC — Matriz de mínimo privilegio (§13)
# ===========================================================================

resource "azurerm_role_assignment" "api_acr_pull" {
  count                = var.create_container_registry ? 1 : 0
  scope                = azurerm_container_registry.rag[0].id
  role_definition_name = "AcrPull"
  principal_id         = azurerm_user_assigned_identity.rag_api.principal_id
}

resource "azurerm_role_assignment" "ingestion_acr_pull" {
  count                = var.create_container_registry ? 1 : 0
  scope                = azurerm_container_registry.rag[0].id
  role_definition_name = "AcrPull"
  principal_id         = azurerm_user_assigned_identity.rag_ingestion.principal_id
}

# --- uami-rag-api: solo lectura de índice + consumo de modelos ---
resource "azurerm_role_assignment" "api_search_reader" {
  scope                = azurerm_search_service.rag.id
  role_definition_name = "Search Index Data Reader"
  principal_id         = azurerm_user_assigned_identity.rag_api.principal_id
}

resource "azurerm_role_assignment" "api_openai_user" {
  scope                = azurerm_cognitive_account.openai.id
  role_definition_name = "Cognitive Services OpenAI User"
  principal_id         = azurerm_user_assigned_identity.rag_api.principal_id
}

# --- uami-rag-ingestion: lectura de blobs, consumo de cola, escritura de índice, embeddings ---
resource "azurerm_role_assignment" "ingestion_blob_reader" {
  scope                = azurerm_storage_account.documents.id
  role_definition_name = "Storage Blob Data Reader"
  principal_id         = azurerm_user_assigned_identity.rag_ingestion.principal_id
}

resource "azurerm_role_assignment" "ingestion_queue_processor" {
  scope                = azurerm_storage_account.documents.id
  role_definition_name = "Storage Queue Data Message Processor"
  principal_id         = azurerm_user_assigned_identity.rag_ingestion.principal_id
}

resource "azurerm_role_assignment" "ingestion_search_contributor" {
  scope                = azurerm_search_service.rag.id
  role_definition_name = "Search Index Data Contributor"
  principal_id         = azurerm_user_assigned_identity.rag_ingestion.principal_id
}

resource "azurerm_role_assignment" "ingestion_openai_user" {
  scope                = azurerm_cognitive_account.openai.id
  role_definition_name = "Cognitive Services OpenAI User"
  principal_id         = azurerm_user_assigned_identity.rag_ingestion.principal_id
}

# ===========================================================================
# 12. OBSERVABILIDAD — Trazabilidad y auditoría (§14 Guardrails)
# ===========================================================================

resource "azurerm_monitor_diagnostic_setting" "search" {
  name                       = "diag-rag-search"
  target_resource_id         = azurerm_search_service.rag.id
  log_analytics_workspace_id = var.log_analytics_workspace_id

  enabled_log {
    category = "OperationLogs"
  }

  metric {
    category = "AllMetrics"
  }
}

resource "azurerm_monitor_diagnostic_setting" "openai" {
  name                       = "diag-rag-openai"
  target_resource_id         = azurerm_cognitive_account.openai.id
  log_analytics_workspace_id = var.log_analytics_workspace_id

  enabled_log {
    category = "Audit"
  }
  enabled_log {
    category = "RequestResponse"
  }

  metric {
    category = "AllMetrics"
  }
}

resource "azurerm_monitor_diagnostic_setting" "container_app_environment" {
  name                       = "diag-rag-aca-env"
  target_resource_id         = azurerm_container_app_environment.rag.id
  log_analytics_workspace_id = var.log_analytics_workspace_id

  enabled_log {
    category = "ContainerAppConsoleLogs"
  }
  enabled_log {
    category = "ContainerAppSystemLogs"
  }

  metric {
    category = "AllMetrics"
  }
}

# ===========================================================================
# 13. GOBERNANZA DE IDENTIDADES DE USUARIO FINAL — §13 (Entra ID)
# ===========================================================================
# Grupos de seguridad usados para autorizar el acceso al portal/chatbot. La
# asignación de estos grupos como App Roles del Portal Web / App
# Registration de Entra ID se gestiona fuera de este módulo (depende de la
# app registration corporativa), pero los grupos se crean y gestionan aquí
# de forma centralizada para mantener una única fuente de verdad.

resource "azuread_group" "rag_users" {
  count            = var.create_entra_groups ? 1 : 0
  display_name     = "grp-novahealth-rag-users"
  description      = "Usuarios autorizados a realizar consultas al Chatbot RAG de gobernanza de la Landing Zone."
  owners           = var.entra_group_owners
  security_enabled = true
}

resource "azuread_group" "rag_functional_admins" {
  count            = var.create_entra_groups ? 1 : 0
  display_name     = "grp-novahealth-rag-functional-admins"
  description      = "Gestión funcional del corpus documental del Chatbot RAG (alta/baja/actualización de documentos)."
  owners           = var.entra_group_owners
  security_enabled = true
}

resource "azuread_group" "rag_full_admins" {
  count            = var.create_entra_groups ? 1 : 0
  display_name     = "grp-novahealth-rag-full-admins"
  description      = "Administración completa de la solución RAG (infraestructura, índices, modelos y guardrails)."
  owners           = var.entra_group_owners
  security_enabled = true
}
