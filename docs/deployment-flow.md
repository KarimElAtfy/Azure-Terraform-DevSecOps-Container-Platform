# Deployment Flow

This document describes the CI/CD deployment flow used by the Azure Terraform DevSecOps Container Platform.

The project uses GitHub Actions to validate Pull Requests and automatically deploy the application when changes are merged into the `main` branch.

The deployment process is designed around four key principles:

* Validate changes before merge.
* Avoid static Azure credentials.
* Build immutable container images.
* Verify the deployed application after deployment.

## Overview

The complete workflow is:

```text
Developer
   |
   | opens Pull Request
   v
PR Checks Workflow
   |
   | Terraform validation
   | Docker build
   | Checkov scan
   | Trivy scan
   v
Merge to main
   |
   v
Deploy Workflow
   |
   | Azure OIDC login
   | Docker build
   | Push image to ACR
   | Terraform apply
   | Smoke test
   v
Azure Container App updated
```

## Pull Request Validation

Pull Requests targeting the `main` branch trigger the PR checks workflow.

Workflow file:

```text
.github/workflows/pr-checks.yml
```

The goal of this workflow is to catch issues before they are merged.

It includes:

* Terraform format checks.
* Terraform validation.
* Docker image build validation.
* Checkov Infrastructure as Code scanning.
* Trivy filesystem and image scanning.

## Terraform Checks

The workflow validates all Terraform stacks:

```text
infra/bootstrap
infra/core
infra/app
```

Each stack runs:

```text
terraform fmt -check -recursive
terraform init -backend=false
terraform validate
```

The backend is disabled during Pull Request checks because the workflow does not need to read or update the remote Terraform state.

The goal is only to validate Terraform syntax, formatting and provider configuration.

## Docker Build Check

The PR workflow builds the FastAPI container image.

This validates that:

* The Dockerfile is valid.
* Python dependencies install correctly.
* The application can be packaged into a container image.

This check catches container build issues before they reach the deployment workflow.

## Checkov Scan

Checkov scans Terraform code for Infrastructure as Code misconfigurations.

In the current version, Checkov runs in soft-fail mode.

This means findings are reported in the workflow logs but do not block the Pull Request yet.

This is intentional because the project is designed as a cost-conscious development environment.

Some findings may be related to accepted trade-offs, such as:

* Public Container App ingress.
* Public network access for Key Vault.
* No Private Endpoint in the first version.
* No Azure Firewall or Application Gateway WAF.
* Basic SKU for Azure Container Registry.

These findings should be reviewed and documented rather than ignored.

## Trivy Scan

Trivy scans both the repository filesystem and the built container image.

The workflow separates reporting from blocking.

The report steps show HIGH and CRITICAL findings.

The blocking gate fails only on fixable CRITICAL vulnerabilities in the container image.

This keeps the pipeline actionable while still exposing security findings.

## Merge to Main

Once the Pull Request checks pass, the PR can be merged into `main`.

A push to `main` triggers the deployment workflow.

Workflow file:

```text
.github/workflows/deploy.yml
```

## Azure Authentication with OIDC

The deploy workflow authenticates to Azure using GitHub OIDC.

It does not use a static client secret.

The workflow uses these GitHub repository variables:

```text
AZURE_CLIENT_ID
AZURE_TENANT_ID
AZURE_SUBSCRIPTION_ID
```

These values identify the Azure Managed Identity and tenant/subscription context.

Authentication is based on a Federated Identity Credential configured on the GitHub Actions Managed Identity.

The credential is limited to:

```text
repo:<owner>/<repo>:ref:refs/heads/main
```

This means only workflows from the configured repository and the `main` branch can authenticate as the deployment identity.

## GitHub Actions Managed Identity

The deployment workflow uses a dedicated User Assigned Managed Identity.

This identity is separate from the runtime Managed Identity used by the Container App.

The GitHub Actions identity has:

* `AcrPush` on Azure Container Registry.
* `Storage Blob Data Contributor` on the Terraform state Storage Account.
* `Contributor` on the application Resource Group.

This separation avoids mixing runtime permissions with CI/CD deployment permissions.

## Docker Image Build and Push

The deploy workflow builds the Docker image from the `app/` directory.

The image is tagged with the Git commit SHA:

```text
<acr-login-server>/devsecops-api:<github-sha>
```

Using the commit SHA as the image tag provides traceability.

It links together:

```text
Git commit
Docker image tag
Container App deployment
/version endpoint
```

This makes it possible to verify exactly which commit is running in Azure.

## Azure Container Registry

The image is pushed to Azure Container Registry.

The ACR admin user is disabled.

The workflow authenticates using Azure identity and has `AcrPush` permissions through RBAC.

The runtime Container App later pulls the image using its own Managed Identity with `AcrPull`.

## Terraform App Deployment

The deployment workflow applies only the application stack:

```text
infra/app
```

The app stack deploys or updates the Azure Container App.

It reads shared infrastructure values from the core remote state, including:

* Azure Container Registry login server.
* Container Apps Environment ID.
* Runtime Managed Identity ID.
* Key Vault secret URI.
* Application Insights connection string.

The workflow passes the new image tag and commit SHA to Terraform:

```text
container_image_tag = <github-sha>
git_commit_sha      = <github-sha>
```

This updates the Container App revision with the newly built image.

## Terraform Backend in CI

The real `backend.tf` file is not committed to the repository.

Instead, the deploy workflow creates a temporary backend configuration during the run:

```text
terraform {
  backend "azurerm" {}
}
```

The backend values are passed through GitHub repository variables and workflow environment variables.

This keeps local backend configuration out of Git while still allowing CI/CD to use the remote Terraform state.

## Container App Update

Terraform updates the Azure Container App with:

* The new container image.
* The commit SHA environment variable.
* Existing runtime configuration.
* Existing Key Vault secret reference.
* Existing Application Insights connection string.

Azure Container Apps creates or updates the active revision.

The public ingress endpoint remains stable.

## Smoke Test

After Terraform apply, the workflow retrieves the stable Container App ingress URL.

Then it runs:

```text
scripts/smoke-test-container-app.ps1
```

The smoke test validates:

* `/health`
* `/config`
* `/version`
* `/secret-status`

It checks that:

* The app is healthy.
* The runtime environment is correct.
* Application Insights is configured.
* The Key Vault secret is loaded.
* The secret value is not exposed.
* The deployed commit SHA matches the GitHub commit SHA.

This means the workflow does not stop at infrastructure deployment.

It verifies that the application actually works after deployment.

## Deployment Summary

The deployment workflow writes a GitHub Actions summary containing:

* Container App name.
* Resource Group.
* Deployed image.
* Application URL.
* Commit SHA.

This makes each deployment easier to inspect from the GitHub Actions UI.

## Why This Flow Matters

This deployment flow provides:

* Automated validation before merge.
* Secretless Azure authentication with OIDC.
* Traceable container images.
* Terraform-managed deployment.
* Post-deployment application validation.
* Clear separation between CI/CD identity and runtime identity.

The result is a repeatable and auditable deployment process.

## End-to-End Validation

The complete workflow has been tested using a Pull Request validation cycle:

```text
test branch
   |
   | Pull Request
   v
PR checks
   |
   | merge to main
   v
deploy workflow
   |
   | smoke test
   v
Container App updated successfully
```

This confirms that both Pull Request validation and automated deployment work correctly.