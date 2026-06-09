param(
    [string]$ImageName = "devsecops-api",
    [string]$ImageTag = "local",
    [string]$ContainerName = "devsecops-api-local-test",
    [int]$HostPort = 8000
)

$ErrorActionPreference = "Stop"

$ImageRef = "${ImageName}:${ImageTag}"
$BaseUrl = "http://127.0.0.1:${HostPort}"

Write-Host "Starting local Docker validation..." -ForegroundColor Cyan
Write-Host "Image: $ImageRef"
Write-Host "Container: $ContainerName"
Write-Host "Base URL: $BaseUrl"
Write-Host ""

try {
    Write-Host "Checking Docker Engine..." -ForegroundColor Cyan
    docker info | Out-Null

    Write-Host "Removing previous test container if it exists..." -ForegroundColor Cyan
    $ExistingContainer = docker ps -a --filter "name=^/${ContainerName}$" --format "{{.Names}}"

    if ($ExistingContainer) {
        docker rm -f $ContainerName | Out-Null
    }

    Write-Host "Building Docker image..." -ForegroundColor Cyan
    docker build -t $ImageRef ./app

    Write-Host "Starting test container..." -ForegroundColor Cyan
    docker run -d `
        --name $ContainerName `
        -p "${HostPort}:8000" `
        -e APP_ENV=dev `
        -e APP_REGION=germanywestcentral `
        -e APP_RUNTIME=docker-local `
        -e GIT_COMMIT_SHA=local-script-test `
        -e APP_SECRET_MESSAGE=fake-local-secret `
        $ImageRef | Out-Null

    Write-Host "Waiting for application health check..." -ForegroundColor Cyan

    $Healthy = $false

    for ($Attempt = 1; $Attempt -le 15; $Attempt++) {
        try {
            $HealthResponse = Invoke-RestMethod "$BaseUrl/health" -TimeoutSec 3

            if ($HealthResponse.status -eq "healthy") {
                $Healthy = $true
                break
            }
        }
        catch {
            Start-Sleep -Seconds 2
        }
    }

    if (-not $Healthy) {
        throw "Application did not become healthy in time."
    }

    Write-Host "Testing /health endpoint..." -ForegroundColor Cyan
    $Health = Invoke-RestMethod "$BaseUrl/health"

    if ($Health.status -ne "healthy") {
        throw "Health endpoint returned unexpected status."
    }

    Write-Host "Testing /config endpoint..." -ForegroundColor Cyan
    $Config = Invoke-RestMethod "$BaseUrl/config"

    if ($Config.environment -ne "dev") {
        throw "Config endpoint returned unexpected environment."
    }

    if ($Config.region -ne "germanywestcentral") {
        throw "Config endpoint returned unexpected region."
    }

    if ($Config.runtime -ne "docker-local") {
        throw "Config endpoint returned unexpected runtime."
    }

    Write-Host "Testing /secret-status endpoint..." -ForegroundColor Cyan
    $SecretStatus = Invoke-RestMethod "$BaseUrl/secret-status"

    if ($SecretStatus.secret_loaded -ne $true) {
        throw "Secret status endpoint did not detect the test secret."
    }

    if ($SecretStatus.secret_value_exposed -ne $false) {
        throw "Secret status endpoint is exposing the secret value."
    }

    Write-Host ""
    Write-Host "Local Docker validation completed successfully." -ForegroundColor Green
}
finally {
    Write-Host ""
    Write-Host "Cleaning up test container..." -ForegroundColor Cyan
    docker rm -f $ContainerName 2>$null | Out-Null
}