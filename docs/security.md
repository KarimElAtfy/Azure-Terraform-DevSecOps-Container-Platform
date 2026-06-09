# Security Model

This document describes the security model used by the Azure Terraform DevSecOps Container Platform.

The project is designed around identity-based access, least privilege, secret isolation and automated deployment without static Azure credentials.

## Security Goals

The main security goals of this project are:

* Avoid static credentials wherever possible.
* Use Azure Managed Identity for runtime access.
* Use GitHub OIDC for CI/CD authentication.
* Keep secret values out of Git and Terraform state.
* Disable unnecessary admin credentials.
* Use Azure RBAC for access control.
* Separate runtime permissions from deployment permissions.
* Validate infrastructure and containers through automated security scanning.

## Identity-Based Security

The project uses identity-based access instead of username/password authentication.

There are two main identities:

```text
Runtime Managed Identity
GitHub Actions Managed Identity
```

These identities have different responsibilities and different permissions.

This separation is intentional.

The application runtime should not have the same permissions as the deployment pipeline.

## Runtime Managed Identity

The runtime Managed Identity is used by the Azure Container App.

It allows the running application to access only the resources it needs.

The runtime identity has:

* `AcrPull` on Azure Container Registry.
* `Key Vault Secrets User` on Azure Key Vault.

This means the Container App can:

* Pull its private container image from ACR.
* Read the required secret from Key Vault.

It cannot push images to ACR.

It cannot manage Key Vault.

It cannot modify the infrastructure.

This follows the principle of least privilege.

## GitHub Actions Managed Identity

The GitHub Actions Managed Identity is used by the CI/CD deployment workflow.

It is separate from the runtime identity.

The GitHub Actions identity has:

* `AcrPush` on Azure Container Registry.
* `Storage Blob Data Contributor` on the Terraform state Storage Account.
* `Contributor` on the application Resource Group.

These permissions allow the workflow to:

* Push new Docker images to ACR.
* Read and update the Terraform remote state.
* Apply Terraform changes to the application Resource Group.

The deployment identity does not run inside the application.

It is used only by GitHub Actions during CI/CD execution.

## Why Two Managed Identities?

The project uses two different managed identities because runtime access and deployment access are different problems.

```text
Runtime identity
   |
   | used by the running Container App
   v
Pull image from ACR
Read secret from Key Vault
```

```text
Deployment identity
   |
   | used by GitHub Actions
   v
Push image to ACR
Run Terraform
Update Container App
```

If both roles used the same identity, the running application could potentially have deployment-level permissions.

That would be unnecessary and risky.

By separating the identities, each one receives only the permissions it needs.

## Azure Container Registry Security

Azure Container Registry is used as a private container image registry.

The ACR admin user is disabled.

This is intentional.

Using the ACR admin user would require static username/password credentials.

Instead, this project uses Azure RBAC:

* The runtime Managed Identity has `AcrPull`.
* The GitHub Actions Managed Identity has `AcrPush`.

This avoids storing registry passwords in:

* Terraform variables.
* GitHub secrets.
* Application configuration.
* Container App registry credentials.

The result is a cleaner and safer image access model.

## Key Vault Secret Management

Azure Key Vault is used to store application secrets.

The application secret is named:

```text
app-secret-message
```

The secret value is created outside Terraform.

Terraform creates:

* The Key Vault.
* The RBAC permissions.
* The Container App secret reference.

Terraform does not manage the secret value.

This is intentional because secret values managed by Terraform can be stored in the Terraform state.

The project avoids placing secret values in:

* Git.
* Terraform code.
* `terraform.tfvars`.
* Terraform state.
* GitHub Actions workflow files.

## Key Vault RBAC Model

The project uses Azure RBAC authorization for Key Vault.

The runtime Managed Identity has:

```text
Key Vault Secrets User
```

This allows the Container App to read secrets.

The deployment/user access model gives operational users enough permissions to create or update secrets, without requiring the application to have management permissions.

This keeps runtime access limited.

## Container App Secret Reference

The Azure Container App uses a Key Vault secret reference.

The flow is:

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

The secret value is injected into the application as an environment variable at runtime.

The application exposes only the secret loading status through:

```text
/secret-status
```

The endpoint confirms whether the secret is loaded, but it never exposes the secret value.

This makes it possible to validate secret injection safely.

## GitHub Actions OIDC

The deployment workflow authenticates to Azure using GitHub OIDC.

No Azure client secret is stored in GitHub.

The workflow uses repository variables:

```text
AZURE_CLIENT_ID
AZURE_TENANT_ID
AZURE_SUBSCRIPTION_ID
```

These are identifiers, not passwords.

The actual trust relationship is handled through a Federated Identity Credential on the GitHub Actions Managed Identity.

The federated credential is limited to the repository and the `main` branch.

This means only workflows from the configured repository and branch can authenticate as the deployment identity.

## Why OIDC Instead of Client Secrets?

A traditional Azure service principal often requires a client secret.

That secret has to be stored somewhere, usually in GitHub Secrets.

This project avoids that model.

With OIDC:

* No long-lived Azure password is stored in GitHub.
* Tokens are short-lived.
* Authentication is based on a trust relationship between GitHub and Azure.
* Access can be restricted to a specific repository and branch.

This reduces credential management risk.

## Terraform State Security

Terraform state is stored remotely in Azure Storage.

The project uses separate state files:

```text
core.dev.tfstate
app.dev.tfstate
```

The remote state backend is created by the bootstrap stack.

Access to the state storage account is controlled through Azure RBAC.

The GitHub Actions Managed Identity has:

```text
Storage Blob Data Contributor
```

This allows the deployment workflow to read and update the app Terraform state.

Sensitive files are not committed to Git.

The repository ignores:

```text
terraform.tfvars
backend.tf
.terraform/
*.tfstate
*.tfstate.*
```

## Security Scanning

The project includes automated security scanning in the Pull Request workflow.

The workflow uses:

* Checkov for Terraform Infrastructure as Code scanning.
* Trivy for filesystem and container image scanning.

Checkov currently runs in soft-fail mode.

This allows findings to be reviewed without blocking all Pull Requests during the current development version.

Trivy separates reporting from blocking:

* HIGH and CRITICAL findings are reported.
* The blocking gate fails only on fixable CRITICAL image vulnerabilities.

This keeps the pipeline actionable while still exposing security findings.

## Intentional Trade-Offs

This project is designed as a development and portfolio environment.

Some production-grade security controls are intentionally out of scope for the first version.

Current trade-offs include:

* Public ingress enabled for the Container App.
* Public network access enabled for Key Vault.
* No Private Endpoint for ACR or Key Vault.
* No Azure Firewall.
* No NAT Gateway.
* No Application Gateway WAF.
* No private Container Apps environment.
* ACR Basic SKU.

These choices reduce cost and complexity while still demonstrating secure identity, secret management, RBAC, observability and CI/CD automation.

## Production Hardening Improvements

For a production-grade version, the following improvements would be considered:

* Private Endpoint for Azure Key Vault.
* Private Endpoint for Azure Container Registry.
* Private Container Apps Environment.
* Application Gateway with WAF.
* Azure Firewall or controlled egress.
* More restrictive custom RBAC roles for CI/CD.
* Separate dev, staging and production environments.
* GitHub Environments with manual approval gates.
* Azure Policy enforcement.
* Stronger Checkov blocking rules.
* Image signing.
* SBOM generation.
* Centralized alert rules.
* Defender for Cloud integration.

## Summary

The security model of this project is based on:

* Managed Identity instead of static credentials.
* Azure RBAC instead of embedded passwords.
* Key Vault instead of secrets in code.
* OIDC instead of GitHub-stored Azure client secrets.
* Separate identities for runtime and deployment.
* Remote Terraform state with controlled access.
* Automated security scanning on Pull Requests.

The result is a secure, explainable and cost-conscious DevSecOps platform suitable for a development portfolio environment.
