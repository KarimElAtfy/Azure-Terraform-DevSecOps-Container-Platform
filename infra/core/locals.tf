locals {
  resource_group_name = "rg-${var.project_name}-${var.environment}-${var.region_code}"

  log_analytics_workspace_name = "law-${var.project_name}-${var.environment}-${var.region_code}"
  application_insights_name    = "appi-${var.project_name}-${var.environment}-${var.region_code}"

  acr_name = lower("${var.acr_name_prefix}${var.environment}${var.region_code}${random_string.acr_suffix.result}")

  managed_identity_name = "id-${var.project_name}-${var.environment}-${var.region_code}"

  key_vault_name = lower("${var.key_vault_name_prefix}-${var.environment}-${var.region_code}-${random_string.key_vault_suffix.result}")

  common_tags = {
    project     = var.project_name
    environment = var.environment
    owner       = var.owner
    managed_by  = "terraform"
    purpose     = "devsecops-container-platform"
  }
}
