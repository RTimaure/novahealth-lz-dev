# Archivo: modules/rag_infrastructure/outputs.tf

output "storage_account_name" {
  description = "Nombre del Storage Account que almacena el corpus documental de origen."
  value       = azurerm_storage_account.documents.name
}

output "storage_account_id" {
  description = "ID del Storage Account que almacena el corpus documental."
  value       = azurerm_storage_account.documents.id
}

output "documents_container_name" {
  description = "Nombre del contenedor Blob del corpus documental."
  value       = azurerm_storage_container.documents.name
}

output "document_events_queue_name" {
  description = "Nombre de la Storage Queue usada para desacoplar Event Grid del ACA Job de ingestión."
  value       = azurerm_storage_queue.document_events.name
}

output "search_service_name" {
  description = "Nombre del servicio Azure AI Search."
  value       = azurerm_search_service.rag.name
}

output "search_service_endpoint" {
  description = "Endpoint del servicio Azure AI Search."
  value       = "https://${azurerm_search_service.rag.name}.search.windows.net"
}

output "search_index_name" {
  description = "Nombre del índice de Azure AI Search usado por el chatbot RAG."
  value       = var.search_index_name
}

output "openai_account_name" {
  description = "Nombre de la cuenta Azure OpenAI Service."
  value       = azurerm_cognitive_account.openai.name
}

output "openai_endpoint" {
  description = "Endpoint de la cuenta Azure OpenAI Service."
  value       = azurerm_cognitive_account.openai.endpoint
}

output "openai_embedding_deployment_name" {
  description = "Nombre del deployment de embeddings (text-embedding-3-small)."
  value       = azurerm_cognitive_deployment.embedding.name
}

output "openai_chat_deployment_name" {
  description = "Nombre del deployment de generación de respuestas (GPT-4o mini)."
  value       = azurerm_cognitive_deployment.chat.name
}

output "redis_hostname" {
  description = "Hostname del Azure Cache for Redis usado como caché semántica."
  value       = azurerm_redis_cache.rag_cache.hostname
}

output "container_registry_login_server" {
  description = "Login server del Azure Container Registry (ej. acrragprodswe.azurecr.io), usado por novahealth-apps/build-and-push.yml para publicar imágenes. Vacío si create_container_registry = false."
  value       = var.create_container_registry ? azurerm_container_registry.rag[0].login_server : ""
}

output "container_registry_id" {
  description = "ID del Azure Container Registry, usado para asignar roles adicionales (p.ej. AcrPush a la identidad del pipeline de CI). Vacío si create_container_registry = false."
  value       = var.create_container_registry ? azurerm_container_registry.rag[0].id : ""
}

output "container_app_environment_id" {
  description = "ID del Azure Container Apps Environment (modo interno) donde se ejecutan la API RAG y el Job de ingestión."
  value       = azurerm_container_app_environment.rag.id
}

output "rag_api_fqdn" {
  description = "FQDN interno de la API RAG (accesible solo dentro de la VNet de la Landing Zone)."
  value       = azurerm_container_app.rag_api.ingress[0].fqdn
}

output "rag_api_identity_client_id" {
  description = "Client ID de la Managed Identity usada por la API RAG (uami-rag-api-*)."
  value       = azurerm_user_assigned_identity.rag_api.client_id
}

output "rag_ingestion_identity_client_id" {
  description = "Client ID de la Managed Identity usada por el ACA Job de ingestión (uami-rag-ingestion-*)."
  value       = azurerm_user_assigned_identity.rag_ingestion.client_id
}

output "entra_group_ids" {
  description = "Mapa con los Object IDs de los grupos de Entra ID de gobernanza del chatbot RAG (vacío si create_entra_groups = false)."
  value = var.create_entra_groups ? {
    rag_users             = azuread_group.rag_users[0].object_id
    rag_functional_admins = azuread_group.rag_functional_admins[0].object_id
    rag_full_admins       = azuread_group.rag_full_admins[0].object_id
  } : {}
}
