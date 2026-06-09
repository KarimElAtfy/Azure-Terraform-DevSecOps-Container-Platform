variable "name" {
  description = "Name of the Azure Container App."
  type        = string
}

variable "resource_group_name" {
  description = "Name of the Resource Group where the Container App will be created."
  type        = string
}

variable "container_app_environment_id" {
  description = "ID of the Azure Container Apps Environment."
  type        = string
}

variable "managed_identity_id" {
  description = "Resource ID of the User Assigned Managed Identity used by the Container App."
  type        = string
}

variable "acr_login_server" {
  description = "Login server of the Azure Container Registry."
  type        = string
}

variable "container_name" {
  description = "Name of the container inside the Container App."
  type        = string
}

variable "container_image" {
  description = "Full container image reference to deploy."
  type        = string
}

variable "target_port" {
  description = "Target port exposed by the container."
  type        = number
}

variable "cpu" {
  description = "CPU allocated to the container."
  type        = number
}

variable "memory" {
  description = "Memory allocated to the container."
  type        = string
}

variable "min_replicas" {
  description = "Minimum number of replicas."
  type        = number
}

variable "max_replicas" {
  description = "Maximum number of replicas."
  type        = number
}

variable "app_name" {
  description = "Application name exposed as environment variable."
  type        = string
}

variable "app_version" {
  description = "Application version exposed as environment variable."
  type        = string
}

variable "app_env" {
  description = "Application environment exposed as environment variable."
  type        = string
}

variable "app_region" {
  description = "Application region exposed as environment variable."
  type        = string
}

variable "app_runtime" {
  description = "Application runtime exposed as environment variable."
  type        = string
}

variable "git_commit_sha" {
  description = "Git commit SHA exposed as environment variable."
  type        = string
}

variable "app_secret_name" {
  description = "Name of the Container App secret exposed to the application."
  type        = string
}

variable "app_secret_key_vault_uri" {
  description = "Versionless Key Vault secret URI used by the Container App secret reference."
  type        = string
}

variable "applicationinsights_connection_string" {
  description = "Application Insights connection string exposed to the application."
  type        = string
  sensitive   = true
}

variable "tags" {
  description = "Tags assigned to the Container App."
  type        = map(string)
  default     = {}
}
