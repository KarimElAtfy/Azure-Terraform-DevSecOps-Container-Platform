# Cost Management

This document describes the cost-conscious design decisions used in the Azure Terraform DevSecOps Container Platform.

The project is designed as a development and portfolio environment.

The goal is to demonstrate realistic cloud engineering practices without introducing unnecessary enterprise-grade cost or complexity in the first version.

## Cost Management Goals

The main cost management goals are:

* Keep the platform affordable for a personal Azure subscription.
* Avoid overengineering the first version.
* Use managed services where they reduce operational overhead.
* Prefer serverless or consumption-based services where possible.
* Avoid always-on infrastructure unless necessary.
* Keep the architecture explainable and reproducible.
* Clearly document which production-grade features are intentionally out of scope.

## Current Environment Scope

This project currently targets a single development environment:

```text
environment = dev
region      = germanywestcentral
```

It is not designed as a full production platform with multiple environments, strict network isolation, advanced perimeter security, or high availability requirements.

The current version focuses on demonstrating:

* Infrastructure as Code.
* Container deployment.
* Managed Identity.
* Key Vault secret management.
* Azure RBAC.
* Observability.
* GitHub Actions CI/CD.
* OIDC authentication.
* Security scanning.
* Smoke testing.

## Azure Container Apps Instead of AKS

The project uses Azure Container Apps instead of Azure Kubernetes Service.

This is intentional.

Azure Kubernetes Service is powerful, but it would introduce additional operational complexity for this project.

AKS would require thinking about:

* Cluster management.
* Node pools.
* Kubernetes networking.
* Cluster upgrades.
* Ingress controllers.
* Kubernetes RBAC.
* Scaling configuration.
* Add-ons.
* More operational monitoring.
* Potentially higher baseline cost.

For this project, the goal is to deploy a containerized application securely and automatically, not to manage a Kubernetes cluster.

Azure Container Apps provides a better fit because it offers:

* Managed serverless container hosting.
* Built-in ingress.
* Scaling support.
* Integration with Log Analytics.
* Managed Identity support.
* A simpler operational model.

A simple way to explain the decision:

```text
AKS would be like buying a truck to move one backpack.

Powerful, but unnecessary for this version.
```

## Container Apps Scaling Configuration

The Container App is configured with:

```text
min_replicas = 0
max_replicas = 1
```

### Minimum Replicas: 0

Setting minimum replicas to `0` allows the application to scale down when not used.

This reduces cost in a development or portfolio environment where the app does not need to run continuously.

### Maximum Replicas: 1

Setting maximum replicas to `1` prevents unexpected scaling and keeps cost predictable.

In a production environment, this value would likely be higher depending on traffic, availability requirements and performance targets.

For the current scope, one replica is enough to demonstrate the platform.

## Azure Container Registry Basic SKU

The project uses Azure Container Registry with the Basic SKU.

This is intentional because the project only needs:

* Private container image storage.
* Docker image push from GitHub Actions.
* Docker image pull from Azure Container Apps.
* Azure RBAC integration.

The project does not currently require advanced registry capabilities such as geo-replication or higher throughput.

The ACR admin user is disabled regardless of SKU.

Image access is handled through Azure RBAC:

* GitHub Actions Managed Identity uses `AcrPush`.
* Runtime Managed Identity uses `AcrPull`.

## Log Analytics Retention

Log Analytics is used for Container Apps platform and container logs.

For this development environment, retention should be kept low and reasonable.

The goal is to have enough logs for debugging and validation without retaining unnecessary data for long periods.

In a production environment, retention would depend on:

* Compliance requirements.
* Incident response needs.
* Audit requirements.
* Cost constraints.
* Logging volume.

## Application Insights Usage

Application Insights is used to collect application telemetry from the FastAPI application through Azure Monitor OpenTelemetry.

For the current version, Application Insights is used to validate:

* Requests.
* Exceptions.
* Basic telemetry.
* Application behavior after deployment.
* Controlled error generation through `/error-test`.

The project does not currently include advanced dashboards, alert rules or long-term telemetry retention policies.

Those are considered future improvements.

## Why No Azure Firewall in Version 1

Azure Firewall is intentionally out of scope for this version.

Azure Firewall is useful in production environments where centralized network control, inspection and egress filtering are required.

However, it would add cost and complexity that are not necessary for the current development platform.

The current project demonstrates security primarily through:

* Managed Identity.
* Azure RBAC.
* Key Vault.
* Secretless CI/CD.
* ACR admin user disabled.
* Security scanning.
* Least privilege access.

In a production version, Azure Firewall or another controlled egress model could be considered.

## Why No NAT Gateway in Version 1

NAT Gateway is intentionally not used in this version.

NAT Gateway is useful when outbound traffic needs stable public IPs or controlled egress behavior.

This project does not currently require static outbound IPs or advanced egress routing.

Adding NAT Gateway would increase complexity and cost without improving the main learning goals of this version.

## Why No Private Endpoints in Version 1

Private Endpoints are intentionally out of scope for the first version.

Private Endpoints would improve network isolation for services such as:

* Azure Key Vault.
* Azure Container Registry.
* Storage Account.

However, they would also require additional private networking design, DNS configuration and troubleshooting.

For this version, the project focuses on identity-based security and secret management while keeping the network design simple and affordable.

This is a conscious trade-off.

The project does not claim to be a fully private enterprise architecture.

In a production version, Private Endpoints would be a strong hardening improvement.

## Why No Application Gateway or WAF in Version 1

Application Gateway with WAF is intentionally out of scope for the first version.

A WAF would be useful in a production-facing web application to provide additional HTTP-layer protection.

However, this project currently exposes a simple FastAPI demo application through Azure Container Apps ingress.

Adding Application Gateway and WAF would increase cost and complexity.

For this version, the goal is to demonstrate:

* Secure container deployment.
* CI/CD automation.
* Identity-based access.
* Secret management.
* Observability.

In a production version, WAF would be considered if the application became internet-facing with real users and higher risk exposure.

## Why No Private Container Apps Environment in Version 1

The project uses public ingress for the Azure Container App.

This makes the application easy to access, test and demonstrate.

A private Container Apps Environment would provide stronger network isolation, but it would also require additional network design and access patterns.

For a portfolio project, public ingress is acceptable when combined with clear documentation and a future hardening roadmap.

## Cost-Conscious Design Summary

The current cost-conscious choices are:

| Area              | Current Choice                       | Reason                                                    |
| ----------------- | ------------------------------------ | --------------------------------------------------------- |
| Container runtime | Azure Container Apps                 | Managed serverless container hosting without AKS overhead |
| Scaling           | Min 0, Max 1                         | Reduces cost and prevents unexpected scale-out            |
| Registry          | ACR Basic                            | Enough for private image push/pull in dev                 |
| Networking        | Public ingress                       | Simple and testable for portfolio/demo                    |
| Firewall          | Not included                         | Avoids unnecessary cost in v1                             |
| NAT Gateway       | Not included                         | No static outbound IP requirement                         |
| Private Endpoints | Not included                         | Avoids private DNS/networking complexity in v1            |
| WAF               | Not included                         | Out of scope for simple demo API                          |
| Observability     | Log Analytics + Application Insights | Enough for logs and telemetry validation                  |
| Environments      | Single dev environment               | Keeps cost and complexity low                             |

## What Would Change in Production

In a production-grade environment, the following improvements would be considered:

* Separate dev, staging and production environments.
* Private Endpoints for Key Vault, ACR and Storage.
* Private Container Apps Environment.
* Application Gateway with WAF.
* More restrictive ingress.
* Controlled egress through Firewall or NAT Gateway.
* Higher replica limits.
* Autoscaling rules based on real traffic.
* Alert rules and action groups.
* Longer log retention if required.
* Stronger Azure Policy enforcement.
* More restrictive custom RBAC roles.
* Cost budgets and alerts.
* Tag-based cost allocation.
* Production approval gates in GitHub Actions.

## Cost Monitoring Recommendations

For a real Azure environment, cost should be monitored using:

* Azure Cost Management.
* Resource tags.
* Budgets.
* Alerts.
* Regular review of unused resources.
* Log Analytics ingestion monitoring.
* Container Apps scaling and revision review.
* ACR image cleanup policies.

The project already uses tags to make resources easier to identify and track.

## Cleanup Importance

Because this is a cloud project, cleanup is part of cost management.

Unused resources should be destroyed when no longer needed.

The cleanup process is documented in:

```text
docs/cleanup.md
```

The correct destroy order matters because the app stack depends on the core stack, and both depend on the bootstrap remote state.

## Summary

This project is intentionally designed to be cost-conscious.

It avoids expensive or unnecessary enterprise components in the first version while still demonstrating strong cloud engineering practices:

* Infrastructure as Code.
* Managed Identity.
* RBAC.
* Key Vault.
* Private container registry.
* Serverless container runtime.
* Observability.
* CI/CD automation.
* OIDC authentication.
* Security scanning.
* Smoke testing.

The result is a balanced development platform that is realistic, explainable and affordable for a portfolio environment.
