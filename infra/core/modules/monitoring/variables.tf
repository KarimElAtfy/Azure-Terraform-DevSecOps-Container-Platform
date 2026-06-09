variable "log_analytics_workspace_name" {
  description = "Name of the Log Analytics Workspace."
  type        = string
}

variable "application_insights_name" {
  description = "Name of the Application Insights resource."
  type        = string
}

variable "resource_group_name" {
  description = "Name of the Resource Group where monitoring resources will be created."
  type        = string
}

variable "location" {
  description = "Azure region where monitoring resources will be created."
  type        = string
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

variable "tags" {
  description = "Tags assigned to monitoring resources."
  type        = map(string)
  default     = {}
}
