output "resource_group_name" {
  description = "Resource Group containing the Terraform state Storage Account."
  value       = azurerm_resource_group.tfstate.name
}

output "storage_account_name" {
  description = "Storage Account used for Terraform remote state."
  value       = azurerm_storage_account.tfstate.name
}

output "container_name" {
  description = "Blob container used for Terraform remote state."
  value       = azurerm_storage_container.tfstate.name
}

output "location" {
  description = "Azure region used for Terraform state resources."
  value       = azurerm_resource_group.tfstate.location
}

output "current_principal_object_id" {
  description = "Object ID of the Azure principal running this bootstrap."
  value       = data.azurerm_client_config.current.object_id
}
