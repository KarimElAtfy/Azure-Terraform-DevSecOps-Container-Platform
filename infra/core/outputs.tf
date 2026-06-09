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

output "key_vault_name" {
  description = "Name of the Azure Key Vault."
  value       = module.key_vault.name
}

output "key_vault_id" {
  description = "ID of the Azure Key Vault."
  value       = module.key_vault.id
}

output "key_vault_uri" {
  description = "URI of the Azure Key Vault."
  value       = module.key_vault.uri
}

output "app_secret_name" {
  description = "Name of the application secret expected in Azure Key Vault."
  value       = var.app_secret_name
}

output "app_secret_versionless_uri" {
  description = "Versionless URI of the application secret expected in Azure Key Vault."
  value       = "${module.key_vault.uri}secrets/${var.app_secret_name}"
}

output "key_vault_secrets_user_role_assignment_id" {
  description = "ID of the Key Vault Secrets User role assignment granted to the Managed Identity."
  value       = azurerm_role_assignment.container_app_identity_key_vault_secrets_user.id
}

output "current_user_key_vault_secrets_officer_role_assignment_id" {
  description = "ID of the Key Vault Secrets Officer role assignment granted to the current Azure user."
  value       = azurerm_role_assignment.current_user_key_vault_secrets_officer.id
}

output "container_app_environment_name" {
  description = "Name of the Azure Container Apps Environment."
  value       = module.container_app_environment.name
}

output "container_app_environment_id" {
  description = "ID of the Azure Container Apps Environment."
  value       = module.container_app_environment.id
}

output "container_app_environment_default_domain" {
  description = "Default domain of the Azure Container Apps Environment."
  value       = module.container_app_environment.default_domain
}

output "github_actions_identity_name" {
  description = "Name of the User Assigned Managed Identity used by GitHub Actions."
  value       = module.github_actions_identity.name
}

output "github_actions_identity_id" {
  description = "ID of the User Assigned Managed Identity used by GitHub Actions."
  value       = module.github_actions_identity.id
}

output "github_actions_client_id" {
  description = "Client ID used by GitHub Actions for Azure OIDC login."
  value       = module.github_actions_identity.client_id
}

output "github_actions_principal_id" {
  description = "Principal ID of the GitHub Actions Managed Identity."
  value       = module.github_actions_identity.principal_id
}

output "github_actions_tenant_id" {
  description = "Azure tenant ID used by GitHub Actions."
  value       = data.azurerm_client_config.current.tenant_id
}

output "github_actions_subscription_id" {
  description = "Azure subscription ID used by GitHub Actions."
  value       = data.azurerm_client_config.current.subscription_id
}

output "github_actions_federated_credential_subject" {
  description = "OIDC subject allowed to authenticate from GitHub Actions."
  value       = azurerm_federated_identity_credential.github_actions_main.subject
}
