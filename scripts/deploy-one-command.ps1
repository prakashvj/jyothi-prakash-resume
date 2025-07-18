# Enhanced One-Command Deployment Script for Jyothi's Resume Website
# This script handles validation, infrastructure provisioning, and content deployment

param(
    [string]$Environment = "prod",
    [string]$ConfigPath = "./config",
    [switch]$SkipProvisioning,
    [switch]$ForceRedeploy,
    [switch]$SkipValidation
)

# Import configuration module
Import-Module "$PSScriptRoot\ConfigModule.psm1" -Force

function Write-DeployLog {
    param([string]$Message, [string]$Level = "INFO")
    $timestamp = Get-Date -Format "HH:mm:ss"
    $color = switch ($Level) {
        "ERROR" { "Red" }
        "WARN" { "Yellow" }
        "SUCCESS" { "Green" }
        "INFO" { "Cyan" }
        default { "White" }
    }
    Write-Host "[$timestamp] $Message" -ForegroundColor $color
}

function Test-Prerequisites {
    Write-DeployLog "🔍 Validating deployment prerequisites..." "INFO"
    $validationsPassed = $true

    # Check Azure CLI
    try {
        $null = az version 2>$null
        if ($LASTEXITCODE -eq 0) {
            Write-DeployLog "✅ Azure CLI is available" "SUCCESS"
        } else {
            Write-DeployLog "❌ Azure CLI not found. Please install it first." "ERROR"
            $validationsPassed = $false
        }
    } catch {
        Write-DeployLog "❌ Azure CLI not found. Please install it first." "ERROR"
        $validationsPassed = $false
    }

    # Check Azure authentication
    try {
        $account = az account show --query "name" --output tsv 2>$null
        if ($account) {
            Write-DeployLog "✅ Azure authenticated as: $account" "SUCCESS"
        } else {
            Write-DeployLog "❌ Not authenticated to Azure. Run 'az login'" "ERROR"
            $validationsPassed = $false
        }
    } catch {
        Write-DeployLog "❌ Azure authentication failed. Run 'az login'" "ERROR"
        $validationsPassed = $false
    }

    # Check AZD CLI
    try {
        $null = azd version 2>$null
        if ($LASTEXITCODE -eq 0) {
            Write-DeployLog "✅ Azure Developer CLI is available" "SUCCESS"
        } else {
            Write-DeployLog "❌ Azure Developer CLI not found. Please install it first." "ERROR"
            $validationsPassed = $false
        }
    } catch {
        Write-DeployLog "❌ Azure Developer CLI not found. Please install it first." "ERROR"
        $validationsPassed = $false
    }

    # Check source files
    $requiredFiles = @("src/index.html", "src/css/style.css", "azure.yaml", "infra/main.bicep")
    foreach ($file in $requiredFiles) {
        if (Test-Path $file) {
            Write-DeployLog "✅ Found required file: $file" "SUCCESS"
        } else {
            Write-DeployLog "❌ Missing required file: $file" "ERROR"
            $validationsPassed = $false
        }
    }

    # Validate HTML content
    if (Test-Path "src/index.html") {
        $htmlContent = Get-Content "src/index.html" -Raw
        if ($htmlContent -like "*<html*" -and $htmlContent -like "*</html>*") {
            Write-DeployLog "✅ HTML structure validation passed" "SUCCESS"
        } else {
            Write-DeployLog "⚠️ HTML structure validation questionable" "WARN"
        }
    }

    return $validationsPassed
}

Write-DeployLog "🚀 Starting Enhanced One-Command Deployment for Jyothi's Resume Website" "SUCCESS"

# Load configuration
Write-DeployLog "📋 Loading configuration..." "INFO"
$config = Get-DeploymentConfig -Environment $Environment -ConfigPath $ConfigPath

if (-not (Test-ConfigurationValidation -Config $config)) {
    Write-DeployLog "❌ Configuration validation failed" "ERROR"
    exit 1
}

$azureResources = Get-AzureResourceNames -Config $config

Write-DeployLog "Environment: $Environment" "INFO"
Write-DeployLog "Location: $($azureResources.Location)" "INFO"
Write-DeployLog "Resource Group: $($azureResources.ResourceGroup)" "INFO"
Write-DeployLog "Static Web App: $($azureResources.StaticWebApp)" "INFO"

# Run prerequisites validation unless skipped
if (-not $SkipValidation) {
    if (-not (Test-Prerequisites)) {
        Write-DeployLog "❌ Prerequisites validation failed. Cannot proceed with deployment." "ERROR"
        Write-DeployLog "Use -SkipValidation to bypass checks (not recommended)" "WARN"
        exit 1
    }
    Write-DeployLog "✅ All prerequisites validation passed!" "SUCCESS"
} else {
    Write-DeployLog "⚠️ Skipping validation checks as requested" "WARN"
}

# Set environment if not exists
$envExists = azd env list --output json | ConvertFrom-Json | Where-Object { $_.Name -eq $Environment }
if (-not $envExists) {
    Write-DeployLog "📝 Creating new environment: $Environment" "INFO"
    azd env new $Environment
    if ($LASTEXITCODE -ne 0) {
        Write-DeployLog "❌ Failed to create environment!" "ERROR"
        exit 1
    }
}

# Select the environment
Write-DeployLog "🎯 Selecting environment: $Environment" "INFO"
azd env select $Environment
if ($LASTEXITCODE -ne 0) {
    Write-DeployLog "❌ Failed to select environment!" "ERROR"
    exit 1
}

# Set required environment variables from configuration
azd env set AZURE_LOCATION $azureResources.Location
azd env set AZURE_ENV_NAME $azureResources.Environment

if (-not $SkipProvisioning) {
    Write-Host "🏗️ Provisioning Azure resources..." -ForegroundColor Yellow
    
    # Check if resources already exist
    $existingApp = az staticwebapp list --query "[?name=='$($azureResources.StaticWebApp)' && resourceGroup=='$($azureResources.ResourceGroup)']" --output json | ConvertFrom-Json
    
    if ($existingApp -and -not $ForceRedeploy) {
        Write-Host "✅ Static Web App '$($azureResources.StaticWebApp)' already exists. Skipping provisioning." -ForegroundColor Green
        Write-Host "   Use -ForceRedeploy flag to recreate resources if needed." -ForegroundColor Gray
    } else {
        Write-Host "🔧 Running azd provision..." -ForegroundColor Yellow
        azd provision
        if ($LASTEXITCODE -ne 0) {
            Write-Host "❌ Provisioning failed!" -ForegroundColor Red
            exit 1
        }
    }
}

# Deploy the website content
Write-Host "📦 Deploying website content..." -ForegroundColor Yellow

# Get deployment token
$deploymentToken = az staticwebapp secrets list --name $azureResources.StaticWebApp --resource-group $azureResources.ResourceGroup --query "properties.apiKey" --output tsv

if (-not $deploymentToken) {
    Write-Host "❌ Failed to get deployment token!" -ForegroundColor Red
    exit 1
}

# Deploy using Static Web Apps CLI
Write-Host "🚀 Deploying to production..." -ForegroundColor Yellow
npx @azure/static-web-apps-cli deploy src --deployment-token $deploymentToken --env production

if ($LASTEXITCODE -eq 0) {
    # Get the website URL
    $websiteUrl = az staticwebapp show --name $azureResources.StaticWebApp --resource-group $azureResources.ResourceGroup --query "defaultHostname" --output tsv
    
    Write-Host ""
    Write-Host "🎉 DEPLOYMENT SUCCESSFUL!" -ForegroundColor Green
    
    # Configure custom domain if enabled in environment config
    Write-Host "🌐 Configuring custom domain..." -ForegroundColor Cyan
    try {
        & "$PSScriptRoot\configure-custom-domain.ps1" -Environment $Environment
        
        # Check if custom domain was configured
        $rawConfig = Get-RawDeploymentConfig
        $envConfig = $rawConfig.environments.$Environment
        if ($envConfig.azure.customDomain.enabled) {
            $customDomain = $envConfig.azure.customDomain.fullDomain
            Write-Host "✅ Custom domain configured: https://$customDomain" -ForegroundColor Green
            $finalUrl = "https://$customDomain"
        } else {
            $finalUrl = "https://$websiteUrl"
        }
    } catch {
        Write-Host "⚠️  Custom domain configuration skipped: $($_.Exception.Message)" -ForegroundColor Yellow
        $finalUrl = "https://$websiteUrl"
    }
    
    Write-Host ""
    Write-Host "📋 Resume Website Details:" -ForegroundColor Cyan
    Write-Host "   • Name: $($azureResources.StaticWebApp)" -ForegroundColor White
    Write-Host "   • Resource Group: $($azureResources.ResourceGroup)" -ForegroundColor White
    Write-Host "   • Environment: $Environment" -ForegroundColor White
    Write-Host "   • Location: $($azureResources.Location)" -ForegroundColor White
    Write-Host ""
    Write-Host "🌐 Live URL: $finalUrl" -ForegroundColor Green
    Write-Host ""
    Write-Host "✨ Your modern resume with Carter-style design is now live!" -ForegroundColor Magenta
    
    # Open the website (optional)
    $openSite = Read-Host "Would you like to open the website now? (y/N)"
    if ($openSite -eq 'y' -or $openSite -eq 'Y') {
        Start-Process $finalUrl
    }
} else {
    Write-Host "❌ Deployment failed!" -ForegroundColor Red
    exit 1
}

Write-Host ""
Write-Host "💡 Next time, just run: .\scripts\deploy-one-command.ps1" -ForegroundColor Cyan
Write-Host "   This will automatically deploy any changes to your live site!" -ForegroundColor Gray
