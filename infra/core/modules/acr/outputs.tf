output "id" {
  description = "ID of the Azure Container Registry."
  value       = azurerm_container_registry.this.id
}

output "name" {
  description = "Name of the Azure Container Registry."
  value       = azurerm_container_registry.this.name
}

output "login_server" {
  description = "Login server URL of the Azure Container Registry."
  value       = azurerm_container_registry.this.login_server
}

output "sku" {
  description = "SKU of the Azure Container Registry."
  value       = azurerm_container_registry.this.sku
}

output "admin_enabled" {
  description = "Whether the Azure Container Registry admin user is enabled."
  value       = azurerm_container_registry.this.admin_enabled
}
