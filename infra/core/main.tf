resource "random_string" "acr_suffix" {
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
