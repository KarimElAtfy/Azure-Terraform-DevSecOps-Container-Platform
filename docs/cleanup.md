# Cleanup Guide

This document describes how to safely destroy the Azure resources created by the Azure Terraform DevSecOps Container Platform.

Cleanup is important because cloud resources can continue generating cost even when the project is not actively used.

## Important Warning

Before running any destroy command, make sure you understand which environment you are targeting.

This project uses Terraform remote state and multiple Terraform stacks.

Destroying resources in the wrong order can cause dependency issues.

The recommended destroy order is:

```text
1. infra/app
2. infra/core
3. infra/bootstrap
```

The bootstrap stack should only be destroyed if you also want to remove the Terraform remote state backend.

## Why Destroy Order Matters

The infrastructure is split into three Terraform stacks:

```text
infra/bootstrap
infra/core
infra/app
```

Each stack has a different responsibility.

### `infra/bootstrap`

Creates the Terraform remote state backend:

* Terraform state Resource Group.
* Storage Account.
* Blob container.

### `infra/core`

Creates the shared Azure platform resources:

* Application Resource Group.
* Azure Container Registry.
* Azure Key Vault.
* Log Analytics.
* Application Insights.
* Managed Identities.
* Container Apps Environment.
* RBAC assignments.
* Federated Identity Credential.

### `infra/app`

Deploys the Azure Container App.

The app stack depends on resources created by the core stack.

The core and app stacks both depend on the remote state backend created by the bootstrap stack.

A simple way to explain the order:

```text
Do not remove the floor while the furniture is still on it.

Remove the application first,
then the platform,
then the state backend.
```

## Files That Must Not Be Committed

Before cleanup or any final repository release, make sure these files are not committed:

```text
terraform.tfvars
backend.tf
.terraform/
*.tfstate
*.tfstate.*
.env
secret files
token files
credential files
```

The repository should only contain example files such as:

```text
terraform.tfvars.example
backend.tf.example
```

## Step 1 — Destroy the App Stack

The app stack should be destroyed first.

This removes the Azure Container App deployment.

Go to the app stack:

```powershell
cd infra\app
```

Make sure the backend file exists locally.

If `backend.tf` does not exist, create it from the example or use your local backend configuration.

Then initialize Terraform:

```powershell
terraform init
```

Review the planned destruction:

```powershell
terraform plan -destroy
```

If the plan looks correct, destroy the app stack:

```powershell
terraform destroy
```

Expected result:

* Azure Container App is removed.
* Shared resources remain untouched.

The following resources should still exist after this step:

* Azure Container Registry.
* Azure Key Vault.
* Log Analytics.
* Application Insights.
* Managed Identities.
* Container Apps Environment.
* Terraform remote state backend.

Return to the repository root:

```powershell
cd ..\..
```

## Step 2 — Destroy the Core Stack

The core stack should be destroyed after the app stack.

Go to the core stack:

```powershell
cd infra\core
```

Initialize Terraform:

```powershell
terraform init
```

Review the planned destruction:

```powershell
terraform plan -destroy
```

If the plan looks correct, destroy the core stack:

```powershell
terraform destroy
```

Expected result:

* Application Resource Group resources are removed.
* Azure Container Registry is removed.
* Key Vault is removed or soft-deleted depending on Azure behavior.
* Log Analytics and Application Insights are removed.
* Managed Identities are removed.
* RBAC assignments are removed.
* Container Apps Environment is removed.

The Terraform remote state backend should still exist after this step.

Return to the repository root:

```powershell
cd ..\..
```

## Step 3 — Destroy the Bootstrap Stack

The bootstrap stack should be destroyed only if you want to remove the Terraform remote state backend.

This step removes the storage backend that stores Terraform state.

Before destroying the bootstrap stack, make sure you no longer need the state files.

Go to the bootstrap stack:

```powershell
cd infra\bootstrap
```

Initialize Terraform:

```powershell
terraform init
```

Review the planned destruction:

```powershell
terraform plan -destroy
```

If the plan looks correct, destroy the bootstrap stack:

```powershell
terraform destroy
```

Expected result:

* Terraform state Resource Group is removed.
* Storage Account is removed.
* Blob container is removed.
* Remote state files are deleted with the storage account.

Return to the repository root:

```powershell
cd ..\..
```

## Key Vault Soft Delete Note

Azure Key Vault may use soft delete behavior.

This means that after destroying the Key Vault, the vault name may remain reserved for a period of time.

If you try to recreate a Key Vault with the same name immediately, Azure may prevent it.

Possible solutions:

* Wait until the soft-deleted vault can be reused.
* Use a new random suffix in the Key Vault name.
* Purge the soft-deleted vault only if you fully understand the impact and have permission to do so.

Check deleted Key Vaults:

```powershell
az keyvault list-deleted --output table
```

Purge a deleted vault only when appropriate:

```powershell
az keyvault purge --name <key-vault-name> --location <azure-region>
```

## Azure Container Registry Image Cleanup

If the core stack is still running but you want to clean old container images, list image tags:

```powershell
az acr repository show-tags `
  --name <acr-name> `
  --repository devsecops-api `
  --output table
```

Delete an old image tag:

```powershell
az acr repository delete `
  --name <acr-name> `
  --image devsecops-api:<tag> `
  --yes
```

This can help reduce registry clutter.

## GitHub Actions Variables

Destroying Azure resources does not automatically remove GitHub repository variables.

If the project is fully retired, review these GitHub variables:

```text
AZURE_CLIENT_ID
AZURE_TENANT_ID
AZURE_SUBSCRIPTION_ID
TFSTATE_RESOURCE_GROUP_NAME
TFSTATE_STORAGE_ACCOUNT_NAME
ACR_NAME
```

They are not passwords, but they may no longer be useful after the infrastructure is destroyed.

## GitHub Actions Workflow Behavior During Cleanup

The deployment workflow runs on pushes to `main`.

During cleanup or after destroying infrastructure, avoid pushing changes that would trigger a deployment unless the infrastructure still exists.

If the infrastructure has already been destroyed, the deploy workflow may fail because resources such as the ACR, Container App or Terraform backend no longer exist.

## Manual Verification After Cleanup

After destroying the app and core stacks, verify that the main application Resource Group is gone or empty:

```powershell
az group show `
  --name rg-devsecops-container-dev-gwc `
  --output table
```

If the group no longer exists, Azure CLI will return an error indicating it was not found.

Verify the Terraform state Resource Group only if you destroyed bootstrap:

```powershell
az group show `
  --name rg-tfstate-devsecops-container-dev-gwc `
  --output table
```

## Recommended Cleanup Strategy

For normal development breaks:

```text
Destroy infra/app only.
```

This removes the running application while keeping shared platform resources and Terraform remote state.

For full environment teardown:

```text
Destroy infra/app.
Destroy infra/core.
Optionally destroy infra/bootstrap.
```

For final project preservation:

```text
Keep infrastructure code in Git.
Keep documentation.
Destroy cloud resources if cost is a concern.
Do not destroy bootstrap unless you no longer need remote state.
```

## Summary

The correct cleanup order is:

```text
1. Destroy infra/app.
2. Destroy infra/core.
3. Destroy infra/bootstrap only if the remote state backend should also be removed.
```

This order avoids dependency issues and keeps the Terraform state backend available until it is no longer needed.

Cleanup is part of responsible cloud engineering because unused cloud resources can continue generating cost.
