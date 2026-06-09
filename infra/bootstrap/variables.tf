variable "project_name" {
  description = "Short project name used for resource naming and tagging."
  type        = string
  default     = "devsecops-container"
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
  description = "Azure region used for the Terraform state resources."
  type        = string
  default     = "germanywestcentral"
}

variable "region_code" {
  description = "Short region code used in resource names."
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

variable "storage_account_prefix" {
  description = "Lowercase alphanumeric prefix for the Terraform state storage account. Keep it short because Azure Storage Account names have strict length limits."
  type        = string
  default     = "sttfdsops"

  validation {
    condition     = can(regex("^[a-z0-9]+$", var.storage_account_prefix)) && length(var.storage_account_prefix) >= 3 && length(var.storage_account_prefix) <= 12
    error_message = "Storage account prefix must be 3-12 characters long and contain only lowercase letters and numbers."
  }
}

variable "state_container_name" {
  description = "Name of the Blob container used to store Terraform state files."
  type        = string
  default     = "tfstate"

  validation {
    condition     = can(regex("^[a-z0-9-]+$", var.state_container_name))
    error_message = "State container name must contain only lowercase letters, numbers, and hyphens."
  }
}
