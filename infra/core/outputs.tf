output "resource_group_name" {
  description = "Name of the main application Resource Group."
  value       = module.resource_group.name
}

output "resource_group_location" {
  description = "Azure region of the main application Resource Group."
  value       = module.resource_group.location
}

output "resource_group_id" {
  description = "ID of the main application Resource Group."
  value       = module.resource_group.id
}

output "log_analytics_workspace_name" {
  description = "Name of the Log Analytics Workspace."
  value       = module.monitoring.log_analytics_workspace_name
}

output "log_analytics_workspace_id" {
  description = "ID of the Log Analytics Workspace."
  value       = module.monitoring.log_analytics_workspace_id
}

output "log_analytics_workspace_customer_id" {
  description = "Workspace customer ID used by Azure services that integrate with Log Analytics."
  value       = module.monitoring.log_analytics_workspace_customer_id
}

output "application_insights_name" {
  description = "Name of the Application Insights resource."
  value       = module.monitoring.application_insights_name
}

output "application_insights_id" {
  description = "ID of the Application Insights resource."
  value       = module.monitoring.application_insights_id
}

output "application_insights_connection_string" {
  description = "Connection string used by applications to send telemetry to Application Insights."
  value       = module.monitoring.application_insights_connection_string
  sensitive   = true
}
