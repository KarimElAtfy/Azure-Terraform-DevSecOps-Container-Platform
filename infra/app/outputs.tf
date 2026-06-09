output "container_app_name" {
  description = "Name of the deployed Azure Container App."
  value       = module.container_app.name
}

output "container_app_id" {
  description = "ID of the deployed Azure Container App."
  value       = module.container_app.id
}

output "container_app_latest_revision_name" {
  description = "Name of the latest Container App revision."
  value       = module.container_app.latest_revision_name
}

output "container_app_latest_revision_fqdn" {
  description = "FQDN of the latest Container App revision."
  value       = module.container_app.latest_revision_fqdn
}

output "container_app_latest_revision_url" {
  description = "HTTPS URL of the latest Container App revision."
  value       = "https://${module.container_app.latest_revision_fqdn}"
}

output "deployed_container_image" {
  description = "Container image deployed to Azure Container Apps."
  value       = module.container_app.container_image
}
