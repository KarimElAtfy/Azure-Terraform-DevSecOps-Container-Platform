variable "name" {
  description = "Name of the User Assigned Managed Identity."
  type        = string
}

variable "resource_group_name" {
  description = "Name of the Resource Group where the identity will be created."
  type        = string
}

variable "location" {
  description = "Azure region where the identity will be created."
  type        = string
}

variable "tags" {
  description = "Tags assigned to the User Assigned Managed Identity."
  type        = map(string)
  default     = {}
}
