variable "name" {
  description = "Name of the Azure Key Vault."
  type        = string

  validation {
    condition     = can(regex("^[a-zA-Z][a-zA-Z0-9-]{1,22}[a-zA-Z0-9]$", var.name))
    error_message = "Key Vault name must be 3-24 characters long, start with a letter, end with a letter or number, and contain only letters, numbers, and hyphens."
  }
}

variable "resource_group_name" {
  description = "Name of the Resource Group where the Key Vault will be created."
  type        = string
}

variable "location" {
  description = "Azure region where the Key Vault will be created."
  type        = string
}

variable "tenant_id" {
  description = "Microsoft Entra tenant ID used by the Key Vault."
  type        = string
}

variable "sku_name" {
  description = "SKU name of the Azure Key Vault."
  type        = string
  default     = "standard"

  validation {
    condition     = contains(["standard", "premium"], var.sku_name)
    error_message = "Key Vault SKU must be either standard or premium."
  }
}

variable "soft_delete_retention_days" {
  description = "Number of days that items should be retained for soft-delete."
  type        = number
  default     = 7

  validation {
    condition     = var.soft_delete_retention_days >= 7 && var.soft_delete_retention_days <= 90
    error_message = "Soft-delete retention must be between 7 and 90 days."
  }
}

variable "tags" {
  description = "Tags assigned to the Azure Key Vault."
  type        = map(string)
  default     = {}
}
