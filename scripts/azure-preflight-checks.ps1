$ErrorActionPreference = "Stop"

Write-Host ""
Write-Host "Azure DevSecOps Container Platform - Preflight Checks" -ForegroundColor Cyan
Write-Host "------------------------------------------------------" -ForegroundColor Cyan
Write-Host ""

function Test-CommandExists {
    param(
        [Parameter(Mandatory = $true)]
        [string]$CommandName
    )

    $Command = Get-Command $CommandName -ErrorAction SilentlyContinue

    if (-not $Command) {
        throw "Required command '$CommandName' was not found in PATH."
    }

    Write-Host "[OK] $CommandName is installed" -ForegroundColor Green
}

function Test-AzureProvider {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Namespace
    )

    $State = az provider show `
        --namespace $Namespace `
        --query "registrationState" `
        -o tsv 2>$null

    if ($State -ne "Registered") {
        Write-Host "[WARN] $Namespace is not registered. Current state: $State" -ForegroundColor Yellow
        Write-Host "       Register it with: az provider register --namespace $Namespace" -ForegroundColor Yellow
    }
    else {
        Write-Host "[OK] $Namespace is registered" -ForegroundColor Green
    }
}

try {
    Write-Host "Checking required local tools..." -ForegroundColor Cyan

    Test-CommandExists "az"
    Test-CommandExists "terraform"
    Test-CommandExists "docker"
    Test-CommandExists "git"

    Write-Host ""
    Write-Host "Checking Docker Engine..." -ForegroundColor Cyan

    docker info | Out-Null
    Write-Host "[OK] Docker Engine is running" -ForegroundColor Green

    Write-Host ""
    Write-Host "Checking Azure login..." -ForegroundColor Cyan

    $Account = az account show --query "{name:name, subscriptionId:id, tenantId:tenantId, user:user.name}" -o json | ConvertFrom-Json

    if (-not $Account.subscriptionId) {
        throw "Azure account not found. Run: az login"
    }

    Write-Host "[OK] Azure account detected" -ForegroundColor Green
    Write-Host "     User: $($Account.user)"
    Write-Host "     Subscription: $($Account.name)"
    Write-Host "     Subscription ID: $($Account.subscriptionId)"
    Write-Host "     Tenant ID: $($Account.tenantId)"

    Write-Host ""
    Write-Host "Checking Azure resource providers..." -ForegroundColor Cyan

    $Providers = @(
        "Microsoft.App",
        "Microsoft.ContainerRegistry",
        "Microsoft.KeyVault",
        "Microsoft.ManagedIdentity",
        "Microsoft.OperationalInsights",
        "Microsoft.Insights",
        "Microsoft.Storage"
    )

    foreach ($Provider in $Providers) {
        Test-AzureProvider $Provider
    }

    Write-Host ""
    Write-Host "Preflight checks completed." -ForegroundColor Green
    Write-Host ""
    Write-Host "If any provider is marked as WARN, register it before running Terraform apply." -ForegroundColor Yellow
}
catch {
    Write-Host ""
    Write-Host "[ERROR] Preflight check failed:" -ForegroundColor Red
    Write-Host $_.Exception.Message -ForegroundColor Red
    exit 1
}