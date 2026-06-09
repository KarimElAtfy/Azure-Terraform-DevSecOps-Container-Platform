locals {
  resource_group_name = "rg-${var.project_name}-${var.environment}-${var.region_code}"

  common_tags = {
    project     = var.project_name
    environment = var.environment
    owner       = var.owner
    managed_by  = "terraform"
    purpose     = "devsecops-container-platform"
  }
}
