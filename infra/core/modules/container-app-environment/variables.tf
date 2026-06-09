variable "name" {
  description = "Name of the Azure Container Apps Environment."
  type        = string
}

variable "resource_group_name" {
  description = "Name of the Resource Group where the Container Apps Environment will be created."
  type        = string
}

variable "location" {
  description = "Azure region where the Container Apps Environment will be created."
  type        = string
}

variable "log_analytics_workspace_id" {
  description = "ID of the Log Analytics Workspace used for Container Apps logs."
  type        = string
}

variable "tags" {
  description = "Tags assigned to the Container Apps Environment."
  type        = map(string)
  default     = {}
}
