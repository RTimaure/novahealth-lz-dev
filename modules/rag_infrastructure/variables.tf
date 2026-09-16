# Archivo: modules/rag_infrastructure/variables.tf
#
# Implementa la arquitectura descrita en "Arquitectura RAG v2.4" y la opción
# "PRODUCCIÓN Enterprise Zero-Trust" de "Documentación Técnica RAG demo_prod":
# ingestión event-driven (Blob Storage -> Event Grid -> Storage Queue -> ACA
# Job con KEDA) + consulta (ACA API -> Azure AI Search -> Azure OpenAI),
# con Managed Identities, red privada (Private Endpoints) y guardrails de
# gobernanza (clasificación, auditoría, límites de tokens).

# ---------------------------------------------------------------------------
# UBICACIÓN Y NOMENCLATURA
# ---------------------------------------------------------------------------

variable "location" {
  description = "Región de Azure donde se despliega la infraestructura RAG (debe coincidir con la VNet/subredes indicadas)."
  type        = string
}

variable "environment_name" {
  description = "Entorno lógico del despliegue: prod (primary) o dr. Se usa en nombres de recursos y tags."
  type        = string
  default     = "prod"

  validation {
    condition     = contains(["prod", "dr"], var.environment_name)
    error_message = "environment_name debe ser 'prod' o 'dr'."
  }
}

variable "region_suffix" {
  description = "Sufijo corto de región usado en la convención de nombres del resto de la Landing Zone (p.ej. 'swe' para SwedenCentral, 'weu' para WestEurope)."
  type        = string
  default     = "swe"
}

variable "resource_group_name" {
  description = "Nombre del Resource Group donde se despliega la infraestructura RAG (rg-rag-prod-swe, dominio apps / suscripción production, proveniente de module.resource_groups.rg_names)."
  type        = string
}

variable "tags" {
  description = "Etiquetas corporativas de gobernanza (owner, costCenter, workload, criticality, etc.), habitualmente module.resource_groups.rg_tags[<rg_key>]."
  type        = map(string)
  default     = {}
}

# ---------------------------------------------------------------------------
# RED: SUBREDES Y DNS PRIVADO (provistas por modules/networking)
# ---------------------------------------------------------------------------

variable "aca_infrastructure_subnet_id" {
  description = "ID de la subred delegada para el Azure Container Apps Environment (p.ej. snet-apps-aca-prod-swe, dominio apps). Debe tener espacio suficiente (/27 o mayor)."
  type        = string
}

variable "private_endpoint_subnet_id" {
  description = "ID de la subred para los Private Endpoints de Storage, AI Search, OpenAI y Redis (p.ej. snet-apps-pe-prod-swe, dominio apps)."
  type        = string
}

variable "private_dns_zone_ids" {
  description = <<-EOT
    Mapa de zonas DNS privadas ya creadas y enlazadas a la VNet por modules/networking
    (output `private_dns_zones`). Debe incluir, al menos, las claves:
    "privatelink.blob.core.windows.net", "privatelink.search.windows.net",
    "privatelink.openai.azure.com" y "privatelink.redis.cache.windows.net".
  EOT
  type        = map(string)
}

# ---------------------------------------------------------------------------
# OBSERVABILIDAD (reutiliza el Log Analytics / App Insights centralizados)
# ---------------------------------------------------------------------------

variable "log_analytics_workspace_id" {
  description = "ID del Log Analytics Workspace centralizado (module.observability.log_analytics_workspace_id) usado para diagnostic settings y para el Container Apps Environment."
  type        = string
}

variable "application_insights_connection_string" {
  description = "Connection String de Application Insights centralizado, inyectada en la API RAG para trazabilidad/auditoría de consultas (usuario, tokens, documentos recuperados)."
  type        = string
  sensitive   = true
}

# ---------------------------------------------------------------------------
# ALMACENAMIENTO DOCUMENTAL
# ---------------------------------------------------------------------------

variable "storage_account_name" {
  description = "Nombre del Storage Account de documentos (3-24 caracteres, minúsculas y dígitos). Debe ser globalmente único en Azure."
  type        = string
}

variable "documents_container_name" {
  description = "Nombre del contenedor Blob donde se almacena el corpus documental de origen."
  type        = string
  default     = "documents"
}

variable "storage_account_replication_type" {
  description = "Tipo de replicación del Storage Account (LRS para demo/dev, GRS/ZRS para producción)."
  type        = string
  default     = "GRS"
}

# ---------------------------------------------------------------------------
# AZURE AI SEARCH
# ---------------------------------------------------------------------------

variable "search_service_name" {
  description = "Nombre del servicio Azure AI Search (motor de recuperación híbrida: vectorial + semántica + palabras clave)."
  type        = string
}

variable "search_sku" {
  description = "SKU de Azure AI Search. 'standard' habilita Semantic Ranking necesario para el diseño de recuperación híbrida."
  type        = string
  default     = "standard"
}

variable "search_index_name" {
  description = "Nombre del índice de Azure AI Search que almacenará los chunks documentales, embeddings y metadatos."
  type        = string
  default     = "novahealth-rag-index"
}

variable "search_replica_count" {
  description = "Número de réplicas del servicio de búsqueda (alta disponibilidad de consultas)."
  type        = number
  default     = 1
}

variable "search_partition_count" {
  description = "Número de particiones del servicio de búsqueda (escalado de almacenamiento/índice)."
  type        = number
  default     = 1
}

# ---------------------------------------------------------------------------
# AZURE CONTAINER REGISTRY
# ---------------------------------------------------------------------------

variable "create_container_registry" {
  description = "Si es true, crea un Azure Container Registry (Premium, sin acceso público, con Private Endpoint) para publicar las imágenes de rag-api y rag-ingestion construidas por el repositorio novahealth-apps. Desactivar en entornos secundarios (p.ej. dr) para reutilizar el ACR ya creado en primary (geo-replicación o referencia externa)."
  type        = bool
  default     = false
}

variable "container_registry_name" {
  description = "Nombre del Azure Container Registry (5-50 caracteres alfanuméricos, sin guiones). Debe ser globalmente único en Azure. Solo se usa si create_container_registry = true."
  type        = string
  default     = ""
}

variable "container_registry_sku" {
  description = "SKU del Azure Container Registry. 'Premium' es obligatorio para poder usar Private Endpoint (Zero-Trust)."
  type        = string
  default     = "Premium"
}

# ---------------------------------------------------------------------------
# AZURE OPENAI
# ---------------------------------------------------------------------------

variable "openai_account_name" {
  description = "Nombre de la cuenta Azure OpenAI Service (Cognitive Account kind=OpenAI)."
  type        = string
}

variable "openai_sku_name" {
  description = "SKU de Azure OpenAI Service."
  type        = string
  default     = "S0"
}

variable "embedding_deployment_name" {
  description = "Nombre del deployment del modelo de embeddings usado para vectorizar chunks y consultas."
  type        = string
  default     = "text-embedding-3-small"
}

variable "embedding_model_version" {
  description = "Versión del modelo de embeddings a desplegar."
  type        = string
  default     = "1"
}

variable "embedding_capacity" {
  description = "Capacidad (TPM en miles) asignada al deployment de embeddings."
  type        = number
  default     = 30
}

variable "chat_deployment_name" {
  description = "Nombre del deployment del modelo de generación de respuestas (seleccionado por equilibrio coste/latencia/calidad)."
  type        = string
  default     = "gpt-4o-mini"
}

variable "chat_model_version" {
  description = "Versión del modelo de chat/generación a desplegar."
  type        = string
  default     = "2024-07-18"
}

variable "chat_capacity" {
  description = "Capacidad (TPM en miles) asignada al deployment de generación de respuestas."
  type        = number
  default     = 30
}

variable "max_output_tokens" {
  description = "Límite de tokens de salida por respuesta del chatbot (guardrail de coste/latencia/calidad, valor recomendado <= 800)."
  type        = number
  default     = 800

  validation {
    condition     = var.max_output_tokens > 0 && var.max_output_tokens <= 4000
    error_message = "max_output_tokens debe estar entre 1 y 4000."
  }
}

# ---------------------------------------------------------------------------
# CACHÉ SEMÁNTICA (REDIS)
# ---------------------------------------------------------------------------

variable "redis_capacity" {
  description = "Tamaño (capacity) del Azure Cache for Redis."
  type        = number
  default     = 0
}

variable "redis_family" {
  description = "Familia del SKU de Redis (C = Basic/Standard, P = Premium)."
  type        = string
  default     = "C"
}

variable "redis_sku_name" {
  description = "SKU de Azure Cache for Redis usado como caché semántica de consultas recurrentes."
  type        = string
  default     = "Standard"
}

# ---------------------------------------------------------------------------
# AZURE CONTAINER APPS: ENTORNO, API Y JOB DE INGESTIÓN
# ---------------------------------------------------------------------------

variable "container_app_environment_name" {
  description = "Nombre del Azure Container Apps Environment (modo interno, sin IP pública, integrado en la VNet de la Landing Zone)."
  type        = string
}

variable "rag_api_name" {
  description = "Nombre de la Container App que expone la API RAG (procesamiento de consultas)."
  type        = string
  default     = "rag-api"
}

variable "rag_api_image" {
  description = "Imagen de contenedor de la API RAG. Placeholder por defecto: sustituir por la imagen real publicada en el Azure Container Registry de la Landing Zone antes de producción."
  type        = string
  default     = "mcr.microsoft.com/azuredocs/aci-helloworld:latest"
}

variable "rag_api_min_replicas" {
  description = "Réplicas mínimas de la API RAG (0 permite scale-to-zero; 1 reduce latencia en frío)."
  type        = number
  default     = 0
}

variable "rag_api_max_replicas" {
  description = "Réplicas máximas de la API RAG."
  type        = number
  default     = 5
}

variable "rag_api_cpu" {
  description = "vCPU asignada a cada réplica de la API RAG."
  type        = number
  default     = 0.5
}

variable "rag_api_memory" {
  description = "Memoria asignada a cada réplica de la API RAG."
  type        = string
  default     = "1Gi"
}

variable "ingestion_job_name" {
  description = "Nombre del ACA Job encargado de la ingestión y (re)indexación documental."
  type        = string
  default     = "rag-ingestion-job"
}

variable "ingestion_job_image" {
  description = "Imagen de contenedor del worker de ingestión (rag_processor.py: extracción, chunking, embeddings e indexación). Placeholder por defecto."
  type        = string
  default     = "mcr.microsoft.com/azuredocs/aci-helloworld:latest"
}

variable "ingestion_job_cpu" {
  description = "vCPU asignada a cada ejecución del ACA Job de ingestión."
  type        = number
  default     = 0.5
}

variable "ingestion_job_memory" {
  description = "Memoria asignada a cada ejecución del ACA Job de ingestión."
  type        = string
  default     = "1Gi"
}

variable "ingestion_job_min_execution_count" {
  description = "Número mínimo de ejecuciones simultáneas del ACA Job (0 = scale-to-zero cuando la cola está vacía)."
  type        = number
  default     = 0
}

variable "ingestion_job_max_execution_count" {
  description = "Número máximo de ejecuciones simultáneas del ACA Job (control de coste y paralelismo de indexación)."
  type        = number
  default     = 5
}

variable "ingestion_job_polling_interval_seconds" {
  description = "Intervalo (segundos) con el que KEDA consulta la longitud de la Storage Queue para decidir el escalado del ACA Job."
  type        = number
  default     = 15
}

variable "ingestion_job_replica_timeout_seconds" {
  description = "Tiempo máximo (segundos) de ejecución de cada réplica del ACA Job antes de marcarse como fallida."
  type        = number
  default     = 1800
}

# ---------------------------------------------------------------------------
# GOBERNANZA DE IDENTIDADES (MICROSOFT ENTRA ID)
# ---------------------------------------------------------------------------

variable "create_entra_groups" {
  description = "Si es true, crea los grupos de Microsoft Entra ID de gobernanza del chatbot (grp-novahealth-rag-*). Desactivar en entornos secundarios (p.ej. dr) para evitar duplicados; reutilizar los IDs generados en primary."
  type        = bool
  default     = true
}

variable "entra_group_owners" {
  description = "Lista de Object IDs (usuarios/service principals) que serán propietarios de los grupos de Entra ID creados para el chatbot RAG."
  type        = list(string)
  default     = []
}
