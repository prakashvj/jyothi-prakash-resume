# Enhanced Quick Deploy Script - Deploy content changes instantly with validation
# Use this when you've made changes to your resume content

param(
    [Parameter(Mandatory=$false)]
    [string]$Environment = "prod",
    
    [Parameter(Mandatory=$false)]
    [string]$ConfigPath = "./config"
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

Write-DeployLog "⚡ Enhanced Quick Deploy - Jyothi's Resume Website" "SUCCESS"

# Load configuration
Write-DeployLog "📋 Loading configuration..." "INFO"
$config = Get-DeploymentConfig -Environment $Environment -ConfigPath $ConfigPath

if (-not (Test-ConfigurationValidation -Config $config)) {
    Write-DeployLog "❌ Configuration validation failed" "ERROR"
    exit 1
}

$azureResources = Get-AzureResourceNames -Config $config

# Validate prerequisites
Write-DeployLog "🔍 Running quick validation checks..." "INFO"

# Check if we're in the right directory
if (-not (Test-Path "src\index.html")) {
    Write-DeployLog "❌ Please run this script from the resume repository root directory" "ERROR"
    exit 1
}

# Validate HTML content
$htmlContent = Get-Content "src\index.html" -Raw
if ($htmlContent -like "*<html*" -and $htmlContent -like "*</html>*") {
    Write-DeployLog "✅ HTML structure validation passed" "SUCCESS"
} else {
    Write-DeployLog "⚠️ HTML structure seems incomplete - continuing anyway" "WARN"
}

# Check Azure authentication
try {
    $account = az account show --query "name" --output tsv 2>$null
    if ($account) {
        Write-DeployLog "✅ Azure authenticated as: $account" "SUCCESS"
    } else {
        Write-DeployLog "❌ Not authenticated to Azure. Run 'az login'" "ERROR"
        exit 1
    }
} catch {
    Write-DeployLog "❌ Azure authentication failed. Run 'az login'" "ERROR"
    exit 1
}

# Get deployment token
Write-DeployLog "🔑 Getting deployment token..." "INFO"
$deploymentToken = az staticwebapp secrets list --name $azureResources.StaticWebApp --resource-group $azureResources.ResourceGroup --query "properties.apiKey" --output tsv

if (-not $deploymentToken) {
    Write-DeployLog "❌ Failed to get deployment token. Make sure you're signed in to Azure." "ERROR"
    Write-DeployLog "Run: az login" "INFO"
    exit 1
}

# Deploy content
Write-DeployLog "🚀 Deploying updated content..." "INFO"
npx @azure/static-web-apps-cli deploy src --deployment-token $deploymentToken --env production

if ($LASTEXITCODE -eq 0) {
    # Get the website URL dynamically
    $websiteUrl = az staticwebapp show --name $azureResources.StaticWebApp --resource-group $azureResources.ResourceGroup --query "defaultHostname" --output tsv
    
    Write-DeployLog "✅ DEPLOYMENT COMPLETE!" "SUCCESS"
    Write-DeployLog "🌐 Your website: https://$websiteUrl" "INFO"
    Write-DeployLog "💡 Changes should be live in 30-60 seconds!" "SUCCESS"
} else {
    Write-DeployLog "❌ Deployment failed!" "ERROR"
    exit 1
}
