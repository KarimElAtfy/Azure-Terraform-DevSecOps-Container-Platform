output "id" {
  description = "ID of the User Assigned Managed Identity."
  value       = azurerm_user_assigned_identity.this.id
}

output "name" {
  description = "Name of the User Assigned Managed Identity."
  value       = azurerm_user_assigned_identity.this.name
}

output "principal_id" {
  description = "Principal ID of the User Assigned Managed Identity."
  value       = azurerm_user_assigned_identity.this.principal_id
}

output "client_id" {
  description = "Client ID of the User Assigned Managed Identity."
  value       = azurerm_user_assigned_identity.this.client_id
}
