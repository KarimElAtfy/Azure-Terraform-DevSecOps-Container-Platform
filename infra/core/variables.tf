variable "project_name" {
  description = "Short project name used for Azure resource naming and tagging."
  type        = string
  default     = "devsecops-container"

  validation {
    condition     = can(regex("^[a-z0-9-]+$", var.project_name))
    error_message = "Project name must contain only lowercase letters, numbers, and hyphens."
  }
}

variable "environment" {
  description = "Deployment environment name."
  type        = string
  default     = "dev"

  validation {
    condition     = can(regex("^[a-z0-9-]+$", var.environment))
    error_message = "Environment must contain only lowercase letters, numbers, and hyphens."
  }
}

variable "location" {
  description = "Azure region used for core platform resources."
  type        = string
  default     = "germanywestcentral"
}

variable "region_code" {
  description = "Short region code used in Azure resource names."
  type        = string
  default     = "gwc"

  validation {
    condition     = can(regex("^[a-z0-9]+$", var.region_code))
    error_message = "Region code must contain only lowercase letters and numbers."
  }
}

variable "owner" {
  description = "Owner tag value."
  type        = string
  default     = "karim-el-atfy"
}

variable "log_retention_in_days" {
  description = "Number of days to retain logs in Log Analytics."
  type        = number
  default     = 30

  validation {
    condition     = var.log_retention_in_days >= 30 && var.log_retention_in_days <= 730
    error_message = "Log retention must be between 30 and 730 days."
  }
}

variable "acr_name_prefix" {
  description = "Lowercase alphanumeric prefix used for the Azure Container Registry name."
  type        = string
  default     = "acrdc"

  validation {
    condition     = can(regex("^[a-z0-9]{3,20}$", var.acr_name_prefix))
    error_message = "ACR name prefix must be 3-20 characters long and contain only lowercase letters and numbers."
  }
}

variable "acr_sku" {
  description = "SKU of the Azure Container Registry."
  type        = string
  default     = "Basic"

  validation {
    condition     = contains(["Basic", "Standard", "Premium"], var.acr_sku)
    error_message = "ACR SKU must be one of: Basic, Standard, Premium."
  }
}

variable "acr_admin_enabled" {
  description = "Whether the Azure Container Registry admin user is enabled."
  type        = bool
  default     = false
}
