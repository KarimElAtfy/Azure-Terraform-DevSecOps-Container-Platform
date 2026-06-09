resource "azurerm_container_app" "this" {
  name                         = var.name
  resource_group_name          = var.resource_group_name
  container_app_environment_id = var.container_app_environment_id
  revision_mode                = "Single"

  identity {
    type         = "UserAssigned"
    identity_ids = [var.managed_identity_id]
  }

  registry {
    server   = var.acr_login_server
    identity = var.managed_identity_id
  }

  secret {
    name                = var.app_secret_name
    key_vault_secret_id = var.app_secret_key_vault_uri
    identity            = var.managed_identity_id
  }

  ingress {
    external_enabled = true
    target_port      = var.target_port
    transport        = "auto"

    traffic_weight {
      percentage      = 100
      latest_revision = true
    }
  }

  template {
    min_replicas = var.min_replicas
    max_replicas = var.max_replicas

    container {
      name   = var.container_name
      image  = var.container_image
      cpu    = var.cpu
      memory = var.memory

      env {
        name  = "APP_NAME"
        value = var.app_name
      }

      env {
        name  = "APP_VERSION"
        value = var.app_version
      }

      env {
        name  = "APP_ENV"
        value = var.app_env
      }

      env {
        name  = "APP_REGION"
        value = var.app_region
      }

      env {
        name  = "APP_RUNTIME"
        value = var.app_runtime
      }

      env {
        name  = "GIT_COMMIT_SHA"
        value = var.git_commit_sha
      }

      env {
        name        = "APP_SECRET_MESSAGE"
        secret_name = var.app_secret_name
      }

      env {
        name  = "APPLICATIONINSIGHTS_CONNECTION_STRING"
        value = var.applicationinsights_connection_string
      }
    }
  }

  tags = var.tags
}
