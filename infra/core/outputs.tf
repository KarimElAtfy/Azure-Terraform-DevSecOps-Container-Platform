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
