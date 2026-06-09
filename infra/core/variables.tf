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
