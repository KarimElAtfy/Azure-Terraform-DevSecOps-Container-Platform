param(
    [Parameter(Mandatory = $true)]
    [string]$AppUrl,

    [string]$ExpectedEnvironment = "dev",
    [string]$ExpectedRegion = "germanywestcentral",
    [string]$ExpectedRuntime = "azure-container-apps",
    [string]$ExpectedCommitSha = ""
)

$ErrorActionPreference = "Stop"

function Invoke-Endpoint {
    param(
        [string]$Url
    )

    for ($i = 1; $i -le 10; $i++) {
        try {
            Write-Host "Requesting $Url - attempt $i/10" -ForegroundColor Cyan
            return Invoke-RestMethod $Url -TimeoutSec 15
        }
        catch {
            if ($i -eq 10) {
                throw "Request failed: $Url"
            }

            Start-Sleep -Seconds 10
        }
    }
}

function Assert-Equal {
    param(
        [string]$Name,
        $Actual,
        $Expected
    )

    if ($Actual -ne $Expected) {
        throw "$Name failed. Expected '$Expected', got '$Actual'."
    }

    Write-Host "[OK] $Name = $Actual" -ForegroundColor Green
}

function Assert-True {
    param(
        [string]$Name,
        $Value
    )

    if ($Value -ne $true) {
        throw "$Name failed. Expected true, got '$Value'."
    }

    Write-Host "[OK] $Name = true" -ForegroundColor Green
}

function Assert-False {
    param(
        [string]$Name,
        $Value
    )

    if ($Value -ne $false) {
        throw "$Name failed. Expected false, got '$Value'."
    }

    Write-Host "[OK] $Name = false" -ForegroundColor Green
}

try {
    $AppUrl = $AppUrl.TrimEnd("/")

    Write-Host ""
    Write-Host "Container App smoke test" -ForegroundColor Cyan
    Write-Host "URL: $AppUrl"
    Write-Host ""

    $Health = Invoke-Endpoint "$AppUrl/health"
    Assert-Equal "Health status" $Health.status "healthy"

    $Config = Invoke-Endpoint "$AppUrl/config"
    Assert-Equal "Environment" $Config.environment $ExpectedEnvironment
    Assert-Equal "Region" $Config.region $ExpectedRegion
    Assert-Equal "Runtime" $Config.runtime $ExpectedRuntime
    Assert-True "Application Insights configured" $Config.app_insights_configured

    $Version = Invoke-Endpoint "$AppUrl/version"
    Write-Host "[OK] App version = $($Version.version)" -ForegroundColor Green
    Write-Host "[OK] Commit SHA = $($Version.commit_sha)" -ForegroundColor Green

    if ($ExpectedCommitSha -ne "") {
        Assert-Equal "Commit SHA" $Version.commit_sha $ExpectedCommitSha
    }

    $SecretStatus = Invoke-Endpoint "$AppUrl/secret-status"
    Assert-Equal "Secret reference" $SecretStatus.secret_reference "configured"
    Assert-True "Secret loaded" $SecretStatus.secret_loaded
    Assert-False "Secret value exposed" $SecretStatus.secret_value_exposed

    Write-Host ""
    Write-Host "Smoke test completed successfully." -ForegroundColor Green
}
catch {
    Write-Host ""
    Write-Host "[ERROR] Smoke test failed:" -ForegroundColor Red
    Write-Host $_.Exception.Message -ForegroundColor Red
    exit 1
}