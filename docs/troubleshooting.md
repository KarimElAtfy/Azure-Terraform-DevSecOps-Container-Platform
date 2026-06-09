# Troubleshooting Guide

This document describes real issues encountered while building the Azure Terraform DevSecOps Container Platform and how they were diagnosed and resolved.

The goal of this guide is to make the project easier to reproduce, debug and explain.

## Why This Document Exists

Cloud projects rarely work perfectly on the first attempt.

This project intentionally documents common and real troubleshooting scenarios related to:

* Docker.
* Terraform.
* Azure resource providers.
* Azure Container Apps.
* Azure RBAC.
* Key Vault.
* GitHub Actions.
* OIDC authentication.
* Security scanning.

Documenting these issues helps demonstrate not only that the platform works, but also that the failure modes were understood and resolved.

## 1. Docker Engine Not Running

### Symptom

During Docker build or Docker run, Docker returned an error similar to:

```text
failed to connect to docker API at npipe...
dockerDesktopLinuxEngine
```

### Cause

Docker Desktop was installed, but the Docker Engine was not running.

The CLI was available, but it could not communicate with the Docker daemon.

### Resolution

Open Docker Desktop and wait until the engine is fully started.

Then verify Docker:

```powershell
docker info
```

If Docker is running correctly, the command returns information about the Docker Engine.

### Lesson Learned

Having the Docker CLI installed is not enough.

The Docker Engine must also be running.

This is why the project includes:

```text
scripts/local-docker-test.ps1
scripts/azure-preflight-checks.ps1
```

These scripts help catch this problem before deployment.

## 2. Terraform Module Not Installed

### Symptom

After adding a new local Terraform module, Terraform validation failed with an error similar to:

```text
Error: Module not installed
Run terraform init
```

### Cause

Terraform had not initialized the newly added local module.

When a new module block is added, Terraform needs to update its module working directory.

### Resolution

Run:

```powershell
terraform init
```

Then run:

```powershell
terraform fmt -recursive
terraform validate
terraform plan
```

### Lesson Learned

Whenever a new Terraform module is added, `terraform init` should be run again.

This happened while adding new infrastructure modules such as monitoring, ACR, identity, Key Vault and Container Apps Environment.

## 3. Azure Resource Provider Not Registered

### Symptom

Creating the Azure Container Apps Environment failed with:

```text
MissingSubscriptionRegistration: The subscription is not registered to use namespace 'Microsoft.App'
```

### Cause

The Azure subscription did not have the `Microsoft.App` resource provider registered.

Azure Container Apps requires this provider.

### Resolution

Register the provider:

```powershell
az provider register --namespace Microsoft.App
```

Check the registration state:

```powershell
az provider show --namespace Microsoft.App --query "registrationState" -o tsv
```

Wait until the result is:

```text
Registered
```

Then rerun:

```powershell
terraform plan
terraform apply
```

### Lesson Learned

Some Azure services require resource providers to be registered before resources can be created.

The project now includes a preflight script that checks important providers:

```text
scripts/azure-preflight-checks.ps1
```

## 4. Key Vault RBAC Propagation Delay

### Symptom

After assigning a Key Vault RBAC role, accessing or creating a secret may return a forbidden or permission-related error.

### Cause

Azure RBAC assignments can take time to propagate.

Terraform may complete successfully, but Azure authorization may not be immediately available.

### Resolution

Wait a few minutes and retry the command.

If needed, refresh the Azure login:

```powershell
az logout
az login
```

Then retry the Key Vault command.

Example:

```powershell
az keyvault secret set `
  --vault-name <key-vault-name> `
  --name app-secret-message `
  --value "This value comes from Azure Key Vault"
```

### Lesson Learned

RBAC is not always instant.

When a role assignment is correct but access fails immediately after creation, propagation delay should be considered before changing code.

## 5. Key Vault Terraform Deprecation Warning

### Symptom

Terraform showed a warning similar to:

```text
enable_rbac_authorization is deprecated
This property has been renamed to rbac_authorization_enabled
```

### Cause

The AzureRM provider renamed the Key Vault RBAC argument.

The old argument still worked, but it was deprecated.

### Resolution

Update the Key Vault resource from:

```hcl
enable_rbac_authorization = true
```

to:

```hcl
rbac_authorization_enabled = true
```

Then run:

```powershell
terraform fmt -recursive
terraform validate
terraform plan
```

### Lesson Learned

Deprecation warnings should not be ignored.

Even if they do not break the current deployment, they can become errors in future provider versions.

## 6. Container App Unavailable Page

### Symptom

Requests to the application returned an Azure Container Apps unavailable page:

```text
Error 404 - This Container App is stopped or does not exist.
```

### Possible Causes

This can happen when:

* The wrong URL is used.
* A revision-specific URL points to an inactive revision.
* The active revision is not running.
* The container failed to start.
* The image could not be pulled.
* The app scaled to zero and needs time to start.

### Diagnosis

Check the Container App status:

```powershell
az containerapp show `
  --name ca-devsecops-api-dev-gwc `
  --resource-group rg-devsecops-container-dev-gwc `
  --query "{provisioningState:properties.provisioningState,runningStatus:properties.runningStatus,latestRevision:properties.latestRevisionName,fqdn:properties.configuration.ingress.fqdn}" `
  --output table
```

List revisions:

```powershell
az containerapp revision list `
  --name ca-devsecops-api-dev-gwc `
  --resource-group rg-devsecops-container-dev-gwc `
  --query "[].{name:name,active:properties.active,trafficWeight:properties.trafficWeight,provisioningState:properties.provisioningState,runningState:properties.runningState,healthState:properties.healthState}" `
  --output table
```

Check logs:

```powershell
az containerapp logs show `
  --name ca-devsecops-api-dev-gwc `
  --resource-group rg-devsecops-container-dev-gwc `
  --follow
```

Check system logs:

```powershell
az containerapp logs show `
  --name ca-devsecops-api-dev-gwc `
  --resource-group rg-devsecops-container-dev-gwc `
  --type system `
  --follow
```

### Resolution

Use the stable ingress FQDN instead of relying on a revision-specific FQDN:

```powershell
$appFqdn = az containerapp show `
  --name ca-devsecops-api-dev-gwc `
  --resource-group rg-devsecops-container-dev-gwc `
  --query "properties.configuration.ingress.fqdn" `
  -o tsv

$appUrl = "https://$appFqdn"
```

Then test:

```powershell
Invoke-RestMethod "$appUrl/health"
```

### Lesson Learned

For smoke tests and user-facing validation, the stable Container App ingress FQDN is preferred over revision-specific URLs.

## 7. Application Telemetry Should Not Break Startup

### Symptom

After adding Application Insights/OpenTelemetry support, there was a risk that a telemetry configuration error could break application startup.

### Cause

If telemetry initialization is not handled safely, an import error or configuration error can stop the application from starting.

### Resolution

The telemetry setup was made fail-safe.

The application tries to configure Azure Monitor OpenTelemetry only if the connection string exists.

If configuration fails, the error is logged as a warning and the app continues to run.

### Lesson Learned

Observability should help diagnose the application.

It should not become a single point of failure.

A simple way to explain this:

```text
If the security camera breaks, the shop should still be able to open.
```

## 8. Secret Loaded but Not Exposed

### Scenario

The application needs to prove that it received the Key Vault secret, but it must not expose the secret value.

### Solution

The `/secret-status` endpoint returns only metadata:

```json
{
  "secret_reference": "configured",
  "secret_loaded": true,
  "secret_value_exposed": false
}
```

### Lesson Learned

Secret validation should prove that the secret is available without leaking the secret value.

A simple way to explain this:

```text
The app confirms it has the key, but it never shows the key.
```

## 9. Trivy Fails on Unfixed Base Image Vulnerabilities

### Symptom

The Trivy image scan failed because it found CRITICAL vulnerabilities in the base image.

The vulnerabilities were related to OS packages, not the application dependencies.

Some findings had no fixed version available.

### Cause

Container image scanners can report vulnerabilities from the base operating system.

Some vulnerabilities may not have a patch available yet in the distribution.

Blocking the pipeline on non-fixable vulnerabilities can make the CI process noisy and difficult to use.

### Resolution

The PR workflow separates reporting from blocking.

Trivy report step:

```text
show HIGH and CRITICAL findings
do not fail the pipeline
```

Trivy gate step:

```text
fail only on fixable CRITICAL image vulnerabilities
```

The blocking gate uses:

```text
--ignore-unfixed
```

### Lesson Learned

Security scanning should be actionable.

The pipeline should show important findings, but fail only on issues that can be fixed immediately and are severe enough to block a change.

## 10. Checkov Findings in a Development Environment

### Symptom

Checkov may report findings related to:

* Public ingress.
* Public Key Vault access.
* Missing Private Endpoints.
* Missing WAF.
* Missing advanced networking controls.
* Basic SKU choices.

### Cause

The project is intentionally designed as a cost-conscious development and portfolio environment.

Some enterprise-grade controls are intentionally out of scope for the first version.

### Resolution

Checkov currently runs in soft-fail mode.

Findings are visible in the workflow logs but do not block Pull Requests yet.

Accepted trade-offs are documented in:

```text
docs/security-scanning.md
docs/security.md
```

### Lesson Learned

Security findings should not be ignored.

They should be reviewed, documented and either remediated or accepted with a clear reason.

## 11. App Registration Creation Denied

### Symptom

Trying to create an Entra App Registration failed with:

```text
Insufficient privileges to complete the operation.
```

### Cause

The current Azure user did not have directory permissions to create App Registrations in Microsoft Entra ID.

### Resolution

Instead of using an App Registration, the project uses a User Assigned Managed Identity for GitHub Actions OIDC.

The Managed Identity is created with Terraform inside the Azure subscription.

A Federated Identity Credential is attached to that Managed Identity.

### Lesson Learned

When App Registration creation is restricted, a User Assigned Managed Identity with Federated Identity Credential can be a better path for GitHub Actions OIDC, if the scenario supports it.

This also keeps the deployment identity inside the infrastructure-as-code model.

## 12. GitHub Actions Role Assignments Not Showing with Generic Query

### Symptom

Role assignments for the GitHub Actions Managed Identity did not appear when using a generic `az role assignment list` query.

### Cause

Azure CLI filtering by assignee can sometimes be confusing for managed identities.

The identity existed and Terraform had created the role assignments, but the generic query did not show the expected output.

### Resolution

Query role assignments by exact scope and filter by `principalId`.

Example for the application Resource Group:

```powershell
$githubPrincipalId = terraform output -raw github_actions_principal_id
$resourceGroupId = terraform output -raw resource_group_id

az role assignment list `
  --scope $resourceGroupId `
  --query "[?principalId=='$githubPrincipalId'].{role:roleDefinitionName,principalId:principalId,scope:scope}" `
  --output table
```

Repeat the same approach for:

* Azure Container Registry scope.
* Terraform state Storage Account scope.

### Lesson Learned

When validating RBAC, checking the exact scope is often more reliable than using a broad assignee query.

## 13. GitHub Actions OIDC Variables

### Scenario

The GitHub Actions deploy workflow requires these values:

```text
AZURE_CLIENT_ID
AZURE_TENANT_ID
AZURE_SUBSCRIPTION_ID
TFSTATE_RESOURCE_GROUP_NAME
TFSTATE_STORAGE_ACCOUNT_NAME
ACR_NAME
```

### Decision

These values are stored as GitHub Repository Variables, not Secrets.

### Reason

They are identifiers and configuration values, not passwords.

Authentication is handled by OIDC and Azure RBAC.

No Azure client secret is stored in GitHub.

### Lesson Learned

Not all CI/CD configuration values are secrets.

Secrets should be reserved for sensitive values.

OIDC reduces the need for long-lived credentials.

## 14. Terraform Backend File Not Committed

### Scenario

The real `backend.tf` file is not committed to Git.

### Reason

Backend configuration is environment-specific.

It may include storage account names and state keys.

Instead, the repository includes:

```text
backend.tf.example
```

The GitHub Actions deployment workflow creates a temporary backend configuration during the run and passes backend values through workflow variables.

### Lesson Learned

Keep local backend configuration out of Git.

Use examples and CI-generated configuration for reproducibility.

## 15. Smoke Test Fails After Deployment

### Possible Causes

If the smoke test fails after deployment, possible causes include:

* The app is still starting.
* The wrong URL is used.
* The new revision failed.
* The expected commit SHA does not match.
* Application Insights environment variable is missing.
* Key Vault secret reference failed.
* The app cannot pull the image.

### Diagnosis

Check the deployed URL:

```powershell
$appFqdn = az containerapp show `
  --name ca-devsecops-api-dev-gwc `
  --resource-group rg-devsecops-container-dev-gwc `
  --query "properties.configuration.ingress.fqdn" `
  -o tsv

$appUrl = "https://$appFqdn"
```

Run smoke test manually:

```powershell
.\scripts\smoke-test-container-app.ps1 `
  -AppUrl $appUrl
```

Check version:

```powershell
Invoke-RestMethod "$appUrl/version"
```

Check Container App logs:

```powershell
az containerapp logs show `
  --name ca-devsecops-api-dev-gwc `
  --resource-group rg-devsecops-container-dev-gwc `
  --follow
```

### Lesson Learned

A successful Terraform apply does not automatically mean the application is healthy.

Post-deployment smoke testing is necessary to validate runtime behavior.

## 16. Deploy Workflow Triggered by Documentation Changes

### Scenario

The deploy workflow runs on every push to `main`, including documentation-only changes.

### Current Behavior

This is currently accepted because the workflow is part of the end-to-end validation model.

Every merge to `main` confirms that the build, deployment and smoke test still work.

### Future Improvement

In the future, path filters could be added to avoid deploying on documentation-only changes.

Example future improvement:

```yaml
on:
  push:
    branches:
      - main
    paths:
      - "app/**"
      - "infra/app/**"
      - ".github/workflows/deploy.yml"
      - "scripts/smoke-test-container-app.ps1"
```

### Lesson Learned

Early in a portfolio project, frequent workflow validation is useful.

Later, path filters can reduce unnecessary deployments.

## Summary

The main troubleshooting lessons from this project are:

* Validate local tools before deploying.
* Run `terraform init` after adding modules.
* Check Azure resource provider registration.
* Expect Azure RBAC propagation delays.
* Prefer stable Container App ingress FQDNs for smoke tests.
* Keep observability fail-safe.
* Validate secrets without exposing values.
* Separate scanner reporting from blocking gates.
* Use exact scopes when validating RBAC.
* Avoid static credentials with GitHub OIDC.
* Do not commit real backend or variable files.
* Always validate the application after deployment.

These lessons make the project easier to operate, explain and improve.
