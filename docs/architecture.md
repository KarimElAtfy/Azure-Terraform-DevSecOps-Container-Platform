# Architecture Overview

This document describes the architecture of the Azure Terraform DevSecOps Container Platform.

The goal of this project is to deploy a containerized FastAPI application on Azure using a secure, automated and observable cloud-native workflow.

The platform is built with:

* Terraform for Infrastructure as Code.
* Docker for application containerization.
* Azure Container Registry for private image storage.
* Azure Container Apps for serverless container hosting.
* Managed Identity and Azure RBAC for identity-based access.
* Azure Key Vault for secret management.
* Log Analytics and Application Insights for observability.
* GitHub Actions for CI/CD automation.
* GitHub OIDC for secretless authentication to Azure.

## High-Level Architecture

```text
Developer
   |
   | Pull Request / Push to main
   v
GitHub Actions
   |
   | OIDC authentication
   v
Azure Managed Identity for GitHub Actions
   |
   | AcrPush
   v
Azure Container Registry
   |
   | private image pull using runtime Managed Identity
   v
Azure Container App
   |
   | reads secret reference using runtime Managed Identity
   v
Azure Key Vault

Azure Container App
   |
   | logs and telemetry
   v
Log Analytics + Application Insights
```

## Main Azure Resource Groups

The project uses two main resource groups.

### Terraform State Resource Group

This resource group contains the Azure Storage Account used by Terraform remote state.

```text
rg-tfstate-devsecops-container-dev-gwc
└── Storage Account
    └── Blob Container: tfstate
        ├── core.dev.tfstate
        └── app.dev.tfstate
```

This stack is created by:

```text
infra/bootstrap
```

The bootstrap stack exists because Terraform needs a remote backend before the main infrastructure can safely use remote state.

### Application Resource Group

This resource group contains the application platform resources.

```text
rg-devsecops-container-dev-gwc
├── Azure Container Registry
├── Azure Container Apps Environment
├── Azure Container App
├── Azure Key Vault
├── Log Analytics Workspace
├── Application Insights
├── Runtime User Assigned Managed Identity
└── GitHub Actions User Assigned Managed Identity
```

This resource group is created and managed mainly by:

```text
infra/core
infra/app
```

## Terraform Stack Separation

The infrastructure is split into three Terraform stacks.

### `infra/bootstrap`

The bootstrap stack creates the Terraform remote state backend.

It creates:

* Resource Group for Terraform state.
* Azure Storage Account.
* Blob container for Terraform state files.
* RBAC assignment for Terraform state access.

This stack is intentionally separated because the backend must exist before the other stacks can use it.

### `infra/core`

The core stack creates the shared platform resources.

It creates:

* Main application Resource Group.
* Log Analytics Workspace.
* Application Insights.
* Azure Container Registry.
* Runtime Managed Identity.
* Azure Key Vault.
* Azure Container Apps Environment.
* GitHub Actions Managed Identity.
* RBAC role assignments.
* Federated Identity Credential for GitHub Actions OIDC.

This stack changes less frequently than the application deployment.

### `infra/app`

The app stack deploys the Azure Container App.

It reads outputs from the core stack using Terraform remote state.

It uses core outputs such as:

* Azure Container Registry login server.
* Container Apps Environment ID.
* Runtime Managed Identity ID.
* Key Vault secret URI.
* Application Insights connection string.

This separation keeps the application deployment independent from the shared platform foundation.

## Runtime Flow

At runtime, the request flow is:

```text
User / Browser / API Client
   |
   | HTTPS request
   v
Azure Container App
   |
   | runs FastAPI container
   v
FastAPI application
```

The Container App exposes a public HTTPS endpoint using Azure Container Apps ingress.

The application listens on port `8000` inside the container.

## Container Image Flow

The container image flow is:

```text
GitHub Actions
   |
   | docker build
   v
Docker image
   |
   | docker push
   v
Azure Container Registry
   |
   | image pull using Managed Identity
   v
Azure Container App
```

The Azure Container Registry admin user is disabled.

The runtime Container App does not use registry username/password credentials.

Instead, it uses a User Assigned Managed Identity with the `AcrPull` role on the registry.

This avoids static credentials and keeps image pull access identity-based.

## Secret Management Flow

The secret flow is:

```text
Azure Key Vault
   |
   | secret reference
   v
Azure Container App
   |
   | environment variable
   v
FastAPI application
```

The secret value is stored in Azure Key Vault.

Terraform creates the Key Vault and the RBAC model, but it does not manage the actual secret value.

This is intentional because secret values managed directly by Terraform can be stored in the Terraform state.

The Container App uses its runtime Managed Identity to read the secret reference from Key Vault.

The application exposes only the secret status through the `/secret-status` endpoint.

It never exposes the secret value.

## Identity and Access Model

The project uses two User Assigned Managed Identities.

### Runtime Managed Identity

The runtime Managed Identity is used by the Azure Container App.

It has:

* `AcrPull` on Azure Container Registry.
* `Key Vault Secrets User` on Azure Key Vault.

This identity allows the running application to pull its private image and read Key Vault secrets without static credentials.

### GitHub Actions Managed Identity

The GitHub Actions Managed Identity is used by the CI/CD pipeline.

It has:

* `AcrPush` on Azure Container Registry.
* `Storage Blob Data Contributor` on the Terraform state Storage Account.
* `Contributor` on the application Resource Group.

It is connected to GitHub Actions using a Federated Identity Credential.

The federated credential is limited to the GitHub repository and the `main` branch.

This allows GitHub Actions to authenticate to Azure using OIDC without a client secret.

## Observability Flow

The observability flow is:

```text
Azure Container App
   |
   | platform logs
   v
Log Analytics Workspace

FastAPI application
   |
   | OpenTelemetry telemetry
   v
Application Insights
```

Log Analytics collects platform and container logs.

Application Insights receives application telemetry from the FastAPI app through Azure Monitor OpenTelemetry.

The application also includes a controlled `/error-test` endpoint to validate exception tracking.

The telemetry configuration is fail-safe: if Application Insights configuration fails, the application continues to run.

## CI/CD Flow

The CI/CD flow is:

```text
Pull Request
   |
   v
PR Checks
   |
   | Terraform fmt / validate
   | Docker build
   | Checkov
   | Trivy
   v
Merge to main
   |
   v
Deploy Workflow
   |
   | Azure login via OIDC
   | Docker build
   | Push image to ACR
   | Terraform apply
   | Smoke test
   v
Azure Container App updated
```

The deployment workflow tags the Docker image with the Git commit SHA.

The same SHA is passed to the application as an environment variable.

The `/version` endpoint exposes this value, allowing the smoke test to verify that the deployed application matches the expected commit.

## Cost-Conscious Design Choices

This project is designed for a development and portfolio environment.

Cost-conscious choices include:

* Azure Container Registry Basic SKU.
* Azure Container Apps instead of AKS.
* Minimum replicas set to `0`.
* Maximum replicas set to `1`.
* Log Analytics retention kept low.
* No Azure Firewall.
* No NAT Gateway.
* No Private Endpoints in the first version.
* No Application Gateway or WAF in the first version.

These choices reduce cost and complexity while still demonstrating cloud-native deployment, identity, secret management, observability and CI/CD automation.

## Production Hardening Considerations

For a production-grade environment, future improvements could include:

* Private networking for Container Apps.
* Private Endpoint for Key Vault and ACR.
* Application Gateway with WAF.
* Stricter RBAC roles for the CI/CD identity.
* Separate environments for dev, staging and production.
* Manual approval gates for production deployments.
* Stronger policy enforcement with Azure Policy.
* More restrictive Checkov gates.
* Image signing and SBOM generation.
* Centralized alerting rules and dashboards.