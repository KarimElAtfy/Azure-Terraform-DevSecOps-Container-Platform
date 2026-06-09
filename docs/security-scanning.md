# Security Scanning Strategy

This project includes automated security checks in the Pull Request workflow.

The goal is to detect infrastructure and container security issues early, before changes are merged into the main branch.

## Tools Used

### Checkov

Checkov is used to scan Terraform code for Infrastructure as Code misconfigurations.

In this project, Checkov currently runs in soft-fail mode.

This means that findings are reported in the workflow logs, but they do not block the Pull Request yet.

This is intentional for the current version of the project because some findings are related to design trade-offs made for a cost-conscious development environment.

Examples of intentional trade-offs:

- Public ingress is enabled for the Azure Container App to make the demo accessible and testable.
- Azure Key Vault public network access is enabled because Private Endpoint is intentionally out of scope for this version.
- Azure Container Registry uses the Basic SKU to reduce cost.
- Private networking, Azure Firewall, NAT Gateway, WAF and Private Endpoints are considered future production hardening improvements.

In a production-grade environment, these findings would be reviewed and either remediated or explicitly suppressed with documented reasons.

## Trivy

Trivy is used to scan both the repository filesystem and the built container image.

The workflow includes:

1. A filesystem scan report.
2. A container image scan report.
3. A blocking image security gate.

The report steps show HIGH and CRITICAL findings without failing the pipeline.

The blocking gate fails the pipeline only when CRITICAL vulnerabilities with available fixes are found in the container image.

Unfixed vulnerabilities are ignored in the blocking gate because they may not have a patch available yet in the base image distribution.

This keeps the pipeline useful and actionable while still exposing security findings in the workflow logs.

## Current Security Gate Behavior

| Scan | Scope | Blocks PR |
| --- | --- | --- |
| Terraform fmt | Terraform formatting | Yes |
| Terraform validate | Terraform syntax and provider validation | Yes |
| Docker build | Container build validation | Yes |
| Checkov | Terraform IaC security scan | No, soft-fail |
| Trivy filesystem report | Repository filesystem scan | No, report only |
| Trivy image report | Container image vulnerability report | No, report only |
| Trivy image gate | Fixable CRITICAL image vulnerabilities | Yes |

## Future Improvements

Planned improvements include:

- Reviewing Checkov findings and documenting accepted risks.
- Adding targeted Checkov suppressions only when justified.
- Making selected Checkov checks blocking.
- Adding SARIF upload for security results.
- Adding Software Bill of Materials generation.
- Considering stricter image hardening or distroless images.
- Evaluating private networking for production-like deployments.