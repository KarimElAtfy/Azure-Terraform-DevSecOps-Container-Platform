locals {
  core_outputs = data.terraform_remote_state.core.outputs

  container_image = "${local.core_outputs.acr_login_server}/${var.container_image_repository}:${var.container_image_tag}"

  common_tags = {
    project     = "devsecops-container"
    environment = "dev"
    owner       = "karim-el-atfy"
    managed_by  = "terraform"
    purpose     = "devsecops-container-platform"
  }
}
