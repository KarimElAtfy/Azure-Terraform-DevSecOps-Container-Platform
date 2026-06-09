variable "tfstate_resource_group_name" {
  description = "Resource Group containing the Terraform remote state Storage Account."
  type        = string
}

variable "tfstate_storage_account_name" {
  description = "Storage Account containing Terraform remote state files."
  type        = string
}

variable "tfstate_container_name" {
  description = "Blob container containing Terraform remote state files."
  type        = string
  default     = "tfstate"
}

variable "core_state_key" {
  description = "Blob key of the core infrastructure Terraform state."
  type        = string
  default     = "core.dev.tfstate"
}

variable "container_app_name" {
  description = "Name of the Azure Container App."
  type        = string
  default     = "ca-devsecops-api-dev-gwc"
}

variable "container_name" {
  description = "Name of the container running inside the Azure Container App."
  type        = string
  default     = "devsecops-api"
}

variable "container_image_repository" {
  description = "Repository name of the container image in Azure Container Registry."
  type        = string
  default     = "devsecops-api"
}

variable "container_image_tag" {
  description = "Container image tag to deploy."
  type        = string
  default     = "manual-test"
}

variable "target_port" {
  description = "Port exposed by the container."
  type        = number
  default     = 8000
}

variable "cpu" {
  description = "CPU allocated to the container."
  type        = number
  default     = 0.25
}

variable "memory" {
  description = "Memory allocated to the container."
  type        = string
  default     = "0.5Gi"
}

variable "min_replicas" {
  description = "Minimum number of Container App replicas."
  type        = number
  default     = 0
}

variable "max_replicas" {
  description = "Maximum number of Container App replicas."
  type        = number
  default     = 1
}

variable "app_version" {
  description = "Application version exposed through environment variables."
  type        = string
  default     = "0.1.0"
}

variable "git_commit_sha" {
  description = "Git commit SHA exposed through the /version endpoint."
  type        = string
  default     = "manual-test"
}
