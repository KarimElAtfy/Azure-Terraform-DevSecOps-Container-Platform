# Observability

This document describes the observability model used by the Azure Terraform DevSecOps Container Platform.

The goal of observability in this project is to make the deployed application understandable, traceable and diagnosable after deployment.

The project uses:

* Azure Log Analytics for platform and container logs.
* Azure Application Insights for application telemetry.
* Azure Monitor OpenTelemetry for FastAPI telemetry export.
* Health and diagnostic endpoints in the FastAPI application.
* Automated smoke tests after deployment.

## Observability Goals

The main observability goals are:

* Verify that the application is running.
* Verify that the deployed version matches the expected Git commit.
* Verify that runtime configuration is correct.
* Verify that Key Vault secret injection works.
* Collect logs and telemetry from the running application.
* Capture controlled application errors for validation.
* Keep observability fail-safe so that telemetry issues do not prevent the app from starting.

## Observability Components

The observability layer is based on two Azure services.

```text id="x36oim"
Azure Container App
   |
   | platform and container logs
   v
Log Analytics Workspace
```

```text id="cg6g7c"
FastAPI Application
   |
   | OpenTelemetry telemetry
   v
Application Insights
```

## Log Analytics Workspace

The Log Analytics Workspace is created in the core Terraform stack.

It is used as the central log destination for Azure Container Apps platform logs.

The Container Apps Environment is configured to send logs to Log Analytics.

This allows platform-level troubleshooting for the Container App environment and running containers.

Examples of useful information include:

* Container startup events.
* Container logs.
* Revision status.
* Runtime errors.
* Platform-level diagnostics.

## Application Insights

Application Insights is also created in the core Terraform stack.

It is connected to the Log Analytics Workspace.

Application Insights is used to collect application-level telemetry from the FastAPI service.

This includes:

* Requests.
* Exceptions.
* Logs.
* Traces.
* Application behavior over time.

The application receives the Application Insights connection string through an environment variable:

```text id="vq3qto"
APPLICATIONINSIGHTS_CONNECTION_STRING
```

This value is provided to the Container App by Terraform using the output from the core infrastructure stack.

## OpenTelemetry Integration

The FastAPI app uses Azure Monitor OpenTelemetry to send telemetry to Application Insights.

The application checks whether the Application Insights connection string is available.

If the connection string exists, the app configures Azure Monitor OpenTelemetry.

If the connection string is missing or the telemetry setup fails, the app continues running.

This is intentional.

Observability should help diagnose the system, but it should not become a reason for the application to fail during startup.

## Fail-Safe Telemetry Configuration

The application telemetry setup is wrapped in a safe initialization block.

The intended behavior is:

```text id="2bl52b"
Application Insights connection string exists
   |
   v
Try to configure Azure Monitor OpenTelemetry
   |
   ├── success → telemetry is enabled
   |
   └── failure → warning is logged, app keeps running
```

This protects the application from failing because of an observability configuration issue.

A simple way to explain this is:

```text id="igjzx2"
If the security camera breaks, the shop should still be able to open.
```

In the same way, if telemetry configuration fails, the API should still start and serve requests.

## Application Diagnostic Endpoints

The FastAPI application exposes several endpoints that support observability and validation.

### `/health`

The `/health` endpoint confirms that the application is running.

Expected response:

```json id="vj0oqp"
{
  "status": "healthy",
  "timestamp_utc": "..."
}
```

This endpoint is used by:

* Local Docker validation.
* Container health validation.
* Smoke testing after deployment.

### `/config`

The `/config` endpoint exposes non-sensitive runtime configuration.

It confirms:

* Environment.
* Region.
* Runtime.
* Whether Application Insights is configured.

Expected values in Azure:

```text id="5p50oy"
environment = dev
region = germanywestcentral
runtime = azure-container-apps
app_insights_configured = true
```

This endpoint does not expose sensitive values.

### `/version`

The `/version` endpoint exposes the application version and Git commit SHA.

This is used to verify deployment traceability.

The deployment workflow builds and pushes the Docker image using the Git commit SHA as the image tag.

The same SHA is passed into the Container App as an environment variable.

The `/version` endpoint makes it possible to verify that the running app matches the expected commit.

Flow:

```text id="1614lq"
Git commit SHA
   |
   | used as Docker image tag
   v
Azure Container Registry
   |
   | deployed by Terraform
   v
Azure Container App
   |
   | exposed by /version
   v
Smoke test verifies expected SHA
```

### `/secret-status`

The `/secret-status` endpoint validates Key Vault secret injection.

It confirms whether the application has received the expected secret at runtime.

It does not expose the secret value.

Expected response:

```json id="k6hrpk"
{
  "secret_reference": "configured",
  "secret_loaded": true,
  "secret_value_exposed": false
}
```

This endpoint is important because it validates the secret management flow without leaking sensitive information.

A simple way to explain it is:

```text id="3e5hun"
The app confirms it has the key, but it never shows the key.
```

### `/error-test`

The `/error-test` endpoint intentionally raises a controlled error.

This endpoint exists to validate error tracking and exception telemetry.

It should not be used as a normal business endpoint.

It is useful during testing because it allows checking whether Application Insights receives controlled failures.

Expected behavior:

* API returns HTTP 500.
* Error is logged by the application.
* Exception telemetry can be inspected in Application Insights.

## Smoke Test Observability Validation

The project includes a smoke test script:

```text id="ctrsqu"
scripts/smoke-test-container-app.ps1
```

The smoke test validates:

* `/health`
* `/config`
* `/version`
* `/secret-status`

It checks that:

* The app is healthy.
* The environment is correct.
* The region is correct.
* The runtime is correct.
* Application Insights is configured.
* The deployed commit SHA matches the expected commit.
* The Key Vault secret is loaded.
* The secret value is not exposed.

This turns observability into an automated validation step.

The deployment workflow does not simply deploy infrastructure.

It also verifies that the deployed application behaves correctly.

## Deployment Workflow Integration

The deploy workflow runs the smoke test after Terraform apply.

Workflow file:

```text id="aw04rj"
.github/workflows/deploy.yml
```

The flow is:

```text id="j9kqmb"
Terraform apply
   |
   v
Resolve Container App URL
   |
   v
Run smoke test
   |
   v
Validate runtime behavior
```

The smoke test receives the expected Git commit SHA from GitHub Actions.

This ensures that the deployed application is not only alive, but also the correct version.

## Container App Logs

Container logs can be inspected using Azure CLI.

Example:

```powershell id="xrlpvm"
az containerapp logs show `
  --name ca-devsecops-api-dev-gwc `
  --resource-group rg-devsecops-container-dev-gwc `
  --follow
```

System logs can also be inspected:

```powershell id="5xn75k"
az containerapp logs show `
  --name ca-devsecops-api-dev-gwc `
  --resource-group rg-devsecops-container-dev-gwc `
  --type system `
  --follow
```

Console logs are useful for application output.

System logs are useful for platform-level issues such as:

* Revision activation problems.
* Container startup failures.
* Image pull issues.
* Scaling or provisioning errors.

## Application Insights Validation

Application Insights can be used to inspect application telemetry.

Useful areas include:

* Transaction search.
* Failures.
* Performance.
* Logs.
* Exceptions.

The `/error-test` endpoint can be called to generate a controlled exception and validate that errors appear in Application Insights.

Example test:

```powershell id="d1nrng"
try {
    Invoke-RestMethod "$appUrl/error-test"
} catch {
    Write-Host "Controlled error generated successfully."
}
```

After a few minutes, the controlled failure can be reviewed in Application Insights.

## Troubleshooting Examples

### Application is unavailable

If the app returns an Azure Container Apps unavailable page, possible causes include:

* The active revision is not running.
* The container failed during startup.
* The image could not be pulled.
* The wrong revision URL is being used.
* The app has scaled to zero and needs time to start.

Useful checks:

```powershell id="mr55jd"
az containerapp show `
  --name ca-devsecops-api-dev-gwc `
  --resource-group rg-devsecops-container-dev-gwc `
  --query "{provisioningState:properties.provisioningState,runningStatus:properties.runningStatus,latestRevision:properties.latestRevisionName}" `
  --output table
```

### Secret is not loaded

If `/secret-status` returns `secret_loaded = false`, possible causes include:

* Key Vault secret does not exist.
* Managed Identity does not have `Key Vault Secrets User`.
* RBAC propagation delay.
* Container App secret reference is misconfigured.

Useful checks:

```powershell id="exsj50"
az keyvault secret show `
  --vault-name <key-vault-name> `
  --name app-secret-message `
  --query "{name:name,enabled:attributes.enabled}" `
  --output table
```

### Application Insights is not configured

If `/config` returns `app_insights_configured = false`, possible causes include:

* Connection string output was not passed to the app stack.
* Container App environment variable is missing.
* Terraform app stack did not apply correctly.

Useful checks:

```powershell id="mm77c2"
az containerapp show `
  --name ca-devsecops-api-dev-gwc `
  --resource-group rg-devsecops-container-dev-gwc `
  --query "properties.template.containers[0].env" `
  --output table
```

## Design Trade-Offs

This observability setup is designed for a development and portfolio environment.

It intentionally avoids a more complex production monitoring setup.

Current trade-offs include:

* No custom dashboards yet.
* No alert rules yet.
* No action groups yet.
* No SLO or SLA tracking.
* No distributed tracing across multiple services because the project currently has one app.
* No centralized multi-environment monitoring because the project currently targets one dev environment.

These are acceptable for the current scope.

## Future Improvements

Future observability improvements could include:

* Custom Application Insights dashboards.
* Azure Monitor alert rules.
* Action groups for notifications.
* Availability tests.
* Container App scaling metrics.
* Log-based alerts.
* Structured JSON logging.
* Correlation IDs.
* More detailed OpenTelemetry spans.
* Separate dashboards for dev, staging and production.
* Integration with Microsoft Defender for Cloud recommendations.

## Summary

The observability model provides:

* Platform logs through Log Analytics.
* Application telemetry through Application Insights.
* OpenTelemetry integration in the FastAPI app.
* Safe validation endpoints.
* Controlled error generation.
* Post-deployment smoke testing.
* Commit-level deployment verification.

This makes the platform easier to operate, validate and troubleshoot.
