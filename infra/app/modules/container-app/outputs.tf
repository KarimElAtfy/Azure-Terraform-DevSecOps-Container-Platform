output "id" {
  description = "ID of the Azure Container App."
  value       = azurerm_container_app.this.id
}

output "name" {
  description = "Name of the Azure Container App."
  value       = azurerm_container_app.this.name
}

output "latest_revision_name" {
  description = "Name of the latest Container App revision."
  value       = azurerm_container_app.this.latest_revision_name
}

output "latest_revision_fqdn" {
  description = "FQDN of the latest Container App revision."
  value       = azurerm_container_app.this.latest_revision_fqdn
}

output "container_image" {
  description = "Container image deployed to the Azure Container App."
  value       = var.container_image
}
