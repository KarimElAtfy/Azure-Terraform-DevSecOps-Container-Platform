data "azurerm_client_config" "current" {}

data "azurerm_storage_account" "tfstate" {
  name                = var.tfstate_storage_account_name
  resource_group_name = var.tfstate_resource_group_name
}

resource "random_string" "acr_suffix" {
  length  = 6
  upper   = false
  special = false
}

resource "random_string" "key_vault_suffix" {
  length  = 6
  upper   = false
  special = false
}

module "resource_group" {
  source = "./modules/resource-group"

  name     = local.resource_group_name
  location = var.location
  tags     = local.common_tags
}

module "monitoring" {
  source = "./modules/monitoring"

  log_analytics_workspace_name = local.log_analytics_workspace_name
  application_insights_name    = local.application_insights_name
  resource_group_name          = module.resource_group.name
  location                     = module.resource_group.location
  log_retention_in_days        = var.log_retention_in_days
  tags                         = local.common_tags
}

module "acr" {
  source = "./modules/acr"

  name                = local.acr_name
  resource_group_name = module.resource_group.name
  location            = module.resource_group.location
  sku                 = var.acr_sku
  admin_enabled       = var.acr_admin_enabled
  tags                = local.common_tags
}

module "identity" {
  source = "./modules/identity"

  name                = local.managed_identity_name
  resource_group_name = module.resource_group.name
  location            = module.resource_group.location
  tags                = local.common_tags
}

resource "azurerm_role_assignment" "container_app_identity_acr_pull" {
  scope                = module.acr.id
  role_definition_name = "AcrPull"
  principal_id         = module.identity.principal_id
  principal_type       = "ServicePrincipal"

  skip_service_principal_aad_check = true
}

module "key_vault" {
  source = "./modules/key-vault"

  name                       = local.key_vault_name
  resource_group_name        = module.resource_group.name
  location                   = module.resource_group.location
  tenant_id                  = data.azurerm_client_config.current.tenant_id
  sku_name                   = var.key_vault_sku_name
  soft_delete_retention_days = var.key_vault_soft_delete_retention_days
  tags                       = local.common_tags
}

resource "azurerm_role_assignment" "container_app_identity_key_vault_secrets_user" {
  scope                = module.key_vault.id
  role_definition_name = "Key Vault Secrets User"
  principal_id         = module.identity.principal_id
  principal_type       = "ServicePrincipal"

  skip_service_principal_aad_check = true
}

resource "azurerm_role_assignment" "current_user_key_vault_secrets_officer" {
  scope                = module.key_vault.id
  role_definition_name = "Key Vault Secrets Officer"
  principal_id         = data.azurerm_client_config.current.object_id
}

module "container_app_environment" {
  source = "./modules/container-app-environment"

  name                       = local.container_app_environment_name
  resource_group_name        = module.resource_group.name
  location                   = module.resource_group.location
  log_analytics_workspace_id = module.monitoring.log_analytics_workspace_id
  tags                       = local.common_tags
}

module "github_actions_identity" {
  source = "./modules/identity"

  name                = local.github_actions_identity_name
  resource_group_name = module.resource_group.name
  location            = module.resource_group.location
  tags                = local.common_tags
}

resource "azurerm_federated_identity_credential" "github_actions_main" {
  name                = local.github_actions_federated_credential_name
  resource_group_name = module.resource_group.name
  parent_id           = module.github_actions_identity.id
  issuer              = "https://token.actions.githubusercontent.com"
  subject             = local.github_actions_federated_credential_subject
  audience            = ["api://AzureADTokenExchange"]
}

resource "azurerm_role_assignment" "github_actions_tfstate_blob_contributor" {
  scope                = data.azurerm_storage_account.tfstate.id
  role_definition_name = "Storage Blob Data Contributor"
  principal_id         = module.github_actions_identity.principal_id
  principal_type       = "ServicePrincipal"

  skip_service_principal_aad_check = true
}

resource "azurerm_role_assignment" "github_actions_acr_push" {
  scope                = module.acr.id
  role_definition_name = "AcrPush"
  principal_id         = module.github_actions_identity.principal_id
  principal_type       = "ServicePrincipal"

  skip_service_principal_aad_check = true
}

resource "azurerm_role_assignment" "github_actions_resource_group_contributor" {
  scope                = module.resource_group.id
  role_definition_name = "Contributor"
  principal_id         = module.github_actions_identity.principal_id
  principal_type       = "ServicePrincipal"

  skip_service_principal_aad_check = true
}
