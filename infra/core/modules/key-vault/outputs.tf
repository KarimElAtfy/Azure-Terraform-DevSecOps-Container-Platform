output "id" {
  description = "ID of the Azure Key Vault."
  value       = azurerm_key_vault.this.id
}

output "name" {
  description = "Name of the Azure Key Vault."
  value       = azurerm_key_vault.this.name
}

output "uri" {
  description = "URI of the Azure Key Vault."
  value       = azurerm_key_vault.this.vault_uri
}
