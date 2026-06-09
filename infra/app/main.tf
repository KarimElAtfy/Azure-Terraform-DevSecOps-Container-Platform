data "terraform_remote_state" "core" {
  backend = "azurerm"

  config = {
    resource_group_name  = var.tfstate_resource_group_name
    storage_account_name = var.tfstate_storage_account_name
    container_name       = var.tfstate_container_name
    key                  = var.core_state_key

    use_azuread_auth = true
  }
}

module "container_app" {
  source = "./modules/container-app"

  name                         = var.container_app_name
  resource_group_name          = local.core_outputs.resource_group_name
  container_app_environment_id = local.core_outputs.container_app_environment_id

  managed_identity_id = local.core_outputs.managed_identity_id

  acr_login_server = local.core_outputs.acr_login_server
  container_name   = var.container_name
  container_image  = local.container_image

  target_port  = var.target_port
  cpu          = var.cpu
  memory       = var.memory
  min_replicas = var.min_replicas
  max_replicas = var.max_replicas

  app_name        = "Azure DevSecOps Container Platform"
  app_version     = var.app_version
  app_env         = "dev"
  app_region      = "germanywestcentral"
  app_runtime     = "azure-container-apps"
  git_commit_sha  = var.git_commit_sha
  app_secret_name = local.core_outputs.app_secret_name

  app_secret_key_vault_uri = local.core_outputs.app_secret_versionless_uri

  applicationinsights_connection_string = local.core_outputs.application_insights_connection_string

  tags = local.common_tags
}
