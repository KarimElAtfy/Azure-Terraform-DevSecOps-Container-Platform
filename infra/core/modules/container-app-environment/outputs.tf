output "id" {
  description = "ID of the Azure Container Apps Environment."
  value       = azurerm_container_app_environment.this.id
}

output "name" {
  description = "Name of the Azure Container Apps Environment."
  value       = azurerm_container_app_environment.this.name
}

output "default_domain" {
  description = "Default domain of the Azure Container Apps Environment."
  value       = azurerm_container_app_environment.this.default_domain
}
