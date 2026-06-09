variable "name" {
  description = "Name of the Azure Container Registry."
  type        = string

  validation {
    condition     = can(regex("^[a-z0-9]{5,50}$", var.name))
    error_message = "Azure Container Registry name must be 5-50 characters long and contain only lowercase letters and numbers."
  }
}

variable "resource_group_name" {
  description = "Name of the Resource Group where the Azure Container Registry will be created."
  type        = string
}

variable "location" {
  description = "Azure region where the Azure Container Registry will be created."
  type        = string
}

variable "sku" {
  description = "SKU of the Azure Container Registry."
  type        = string
  default     = "Basic"

  validation {
    condition     = contains(["Basic", "Standard", "Premium"], var.sku)
    error_message = "Azure Container Registry SKU must be one of: Basic, Standard, Premium."
  }
}

variable "admin_enabled" {
  description = "Whether the Azure Container Registry admin user is enabled."
  type        = bool
  default     = false
}

variable "tags" {
  description = "Tags assigned to the Azure Container Registry."
  type        = map(string)
  default     = {}
}
