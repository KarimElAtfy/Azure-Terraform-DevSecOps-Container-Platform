locals {
  resource_group_name = "rg-tfstate-${var.project_name}-${var.environment}-${var.region_code}"

  storage_account_name = lower(
    "${var.storage_account_prefix}${var.environment}${var.region_code}${random_string.storage_suffix.result}"
  )

  common_tags = {
    project     = var.project_name
    environment = var.environment
    owner       = var.owner
    managed_by  = "terraform"
    purpose     = "terraform-remote-state"
  }
}
