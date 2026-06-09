# Diagrams

This document contains the main diagrams for the Azure Terraform DevSecOps Container Platform.

The diagrams are stored as Mermaid source files and exported as SVG images for clean rendering on GitHub.

## Diagram Files

| Diagram | Mermaid Source | SVG Export |
| --- | --- | --- |
| Architecture Overview | `docs/diagrams/architecture-overview.mmd` | `docs/diagrams/architecture-overview.svg` |
| CI/CD Flow | `docs/diagrams/cicd-flow.mmd` | `docs/diagrams/cicd-flow.svg` |
| Identity & Access | `docs/diagrams/identity-access.mmd` | `docs/diagrams/identity-access.svg` |
| Secret & Observability | `docs/diagrams/secret-observability.mmd` | `docs/diagrams/secret-observability.svg` |

## 1. Architecture Overview

![Architecture Overview](diagrams/architecture-overview.svg)

This diagram shows the main Azure resources used by the platform and how the application interacts with Azure Container Registry, Azure Key Vault, Application Insights and Log Analytics.

## 2. CI/CD Flow

![CI/CD Flow](diagrams/cicd-flow.svg)

This diagram shows the workflow from Pull Request validation to deployment on `main`, including Docker build, ACR push, Terraform apply and smoke testing.

## 3. Identity & Access

![Identity & Access](diagrams/identity-access.svg)

This diagram shows the separation between the Runtime Managed Identity and the GitHub Actions Managed Identity, including the roles assigned to each one.

## 4. Secret & Observability

![Secret & Observability](diagrams/secret-observability.svg)

This diagram shows how the application reads the Key Vault secret through Managed Identity and how logs and telemetry flow to Application Insights and Log Analytics.

## Why These Diagrams Matter

The diagrams make the project easier to understand from different perspectives:

- The architecture diagram explains the Azure resources and runtime relationships.
- The CI/CD diagram explains the deployment flow from Pull Request to smoke test.
- The identity diagram explains least privilege and separation of duties.
- The secret and observability diagram explains how secrets and telemetry are handled safely.

Together, they make the platform easier to review, explain and discuss during interviews.