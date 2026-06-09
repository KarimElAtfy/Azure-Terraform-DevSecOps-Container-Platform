output "resource_group_name" {
  description = "Name of the main application Resource Group."
  value       = module.resource_group.name
}

output "resource_group_location" {
  description = "Azure region of the main application Resource Group."
  value       = module.resource_group.location
}

output "resource_group_id" {
  description = "ID of the main application Resource Group."
  value       = module.resource_group.id
}

output "log_analytics_workspace_name" {
  description = "Name of the Log Analytics Workspace."
  value       = module.monitoring.log_analytics_workspace_name
}

output "log_analytics_workspace_id" {
  description = "ID of the Log Analytics Workspace."
  value       = module.monitoring.log_analytics_workspace_id
}

output "log_analytics_workspace_customer_id" {
  description = "Workspace customer ID used by Azure services that integrate with Log Analytics."
  value       = module.monitoring.log_analytics_workspace_customer_id
}

output "application_insights_name" {
  description = "Name of the Application Insights resource."
  value       = module.monitoring.application_insights_name
}

output "application_insights_id" {
  description = "ID of the Application Insights resource."
  value       = module.monitoring.application_insights_id
}

output "application_insights_connection_string" {
  description = "Connection string used by applications to send telemetry to Application Insights."
  value       = module.monitoring.application_insights_connection_string
  sensitive   = true
}

output "acr_name" {
  description = "Name of the Azure Container Registry."
  value       = module.acr.name
}

output "acr_id" {
  description = "ID of the Azure Container Registry."
  value       = module.acr.id
}

output "acr_login_server" {
  description = "Login server of the Azure Container Registry."
  value       = module.acr.login_server
}

output "acr_sku" {
  description = "SKU of the Azure Container Registry."
  value       = module.acr.sku
}

output "acr_admin_enabled" {
  description = "Whether the Azure Container Registry admin user is enabled."
  value       = module.acr.admin_enabled
}

output "managed_identity_name" {
  description = "Name of the User Assigned Managed Identity used by the application runtime."
  value       = module.identity.name
}

output "managed_identity_id" {
  description = "ID of the User Assigned Managed Identity used by the application runtime."
  value       = module.identity.id
}

output "managed_identity_principal_id" {
  description = "Principal ID of the User Assigned Managed Identity, used for Azure RBAC assignments."
  value       = module.identity.principal_id
}

output "managed_identity_client_id" {
  description = "Client ID of the User Assigned Managed Identity."
  value       = module.identity.client_id
}

output "acr_pull_role_assignment_id" {
  description = "ID of the AcrPull role assignment granted to the Managed Identity."
  value       = azurerm_role_assignment.container_app_identity_acr_pull.id
}
