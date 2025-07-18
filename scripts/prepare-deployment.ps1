# Pre-Deployment Resource Validation and Creation Script
# This script ensures all required Azure resources exist before deployment
# Dependencies are checked and created in the correct order

param(
    [Parameter(Mandatory=$false)]
    [string]$Environment = "production",
    
    [Parameter(Mandatory=$false)]
    [string]$ConfigPath = "./config",
    
    [Parameter(Mandatory=$false)]
    [switch]$CreateMissingResources,
    
    [Parameter(Mandatory=$false)]
    [switch]$DryRun
)

Write-Host "=== Pre-Deployment Dependency Validation ===" -ForegroundColor Magenta

# Step 1: Load and validate configuration
Write-Host "`n🔍 Step 1: Loading and validating configuration..." -ForegroundColor Cyan
.\scripts\config-loader.ps1 -Environment $Environment -ConfigPath $ConfigPath -Export -ValidateAzureResources

if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ Configuration validation failed. Cannot proceed with deployment." -ForegroundColor Red
    exit 1
}

# Get exported environment variables
$subscriptionId = $env:AZURE_SUBSCRIPTION_ID
$resourceGroupName = $env:AZURE_RESOURCE_GROUP_NAME
$location = $env:AZURE_LOCATION
$staticWebAppName = $env:AZURE_STATIC_WEB_APP_NAME
$environmentName = $env:AZURE_ENV_NAME

Write-Host "✅ Configuration loaded successfully" -ForegroundColor Green

# Step 2: Check all dependencies and report status
Write-Host "`n🔍 Step 2: Analyzing deployment dependencies..." -ForegroundColor Cyan

$dependencies = @{
    "AzureCLI" = @{
        Name = "Azure CLI"
        Required = $true
        Exists = $false
        Priority = 1
        CheckCommand = "az version"
        Description = "Required for all Azure operations"
    }
    "AzureLogin" = @{
        Name = "Azure Authentication"
        Required = $true
        Exists = $false
        Priority = 2
        CheckCommand = "az account show"
        Description = "Must be logged in to Azure"
    }
    "Subscription" = @{
        Name = "Azure Subscription Access"
        Required = $true
        Exists = $false
        Priority = 3
        CheckCommand = "az account show --subscription $subscriptionId"
        Description = "Access to target subscription"
    }
    "ResourceGroup" = @{
        Name = "Resource Group ($resourceGroupName)"
        Required = $true
        Exists = $false
        Priority = 4
        CheckCommand = "az group show --name $resourceGroupName --subscription $subscriptionId"
        CreateCommand = "az group create --name $resourceGroupName --location $location --subscription $subscriptionId"
        Description = "Container for all Azure resources"
    }
    "StaticWebApp" = @{
        Name = "Static Web App ($staticWebAppName)"
        Required = $false
        Exists = $false
        Priority = 5
        CheckCommand = "az staticwebapp show --name $staticWebAppName --resource-group $resourceGroupName --subscription $subscriptionId"
        Description = "Will be created during deployment if missing"
    }
}

# Check each dependency
foreach ($depKey in $dependencies.Keys | Sort-Object { $dependencies[$_].Priority }) {
    $dep = $dependencies[$depKey]
    Write-Host "   Checking: $($dep.Name)..." -ForegroundColor Gray
    
    try {
        $result = Invoke-Expression "$($dep.CheckCommand) 2>`$null"
        if ($result -and $LASTEXITCODE -eq 0) {
            $dep.Exists = $true
            Write-Host "   ✅ $($dep.Name): Available" -ForegroundColor Green
        } else {
            Write-Host "   ❌ $($dep.Name): Missing" -ForegroundColor Red
        }
    } catch {
        Write-Host "   ❌ $($dep.Name): Missing" -ForegroundColor Red
    }
}

# Step 3: Report dependency status
Write-Host "`n📋 Step 3: Dependency Status Report" -ForegroundColor Cyan

$missingRequired = @()
$missingOptional = @()
$available = @()

foreach ($depKey in $dependencies.Keys | Sort-Object { $dependencies[$_].Priority }) {
    $dep = $dependencies[$depKey]
    
    if ($dep.Exists) {
        $available += $dep
    } elseif ($dep.Required) {
        $missingRequired += $dep
    } else {
        $missingOptional += $dep
    }
}

Write-Host "`n✅ Available Dependencies:" -ForegroundColor Green
foreach ($dep in $available) {
    Write-Host "   • $($dep.Name) - $($dep.Description)" -ForegroundColor Gray
}

if ($missingRequired.Count -gt 0) {
    Write-Host "`n❌ Missing Required Dependencies:" -ForegroundColor Red
    foreach ($dep in $missingRequired) {
        Write-Host "   • $($dep.Name) - $($dep.Description)" -ForegroundColor Gray
    }
}

if ($missingOptional.Count -gt 0) {
    Write-Host "`nℹ️  Missing Optional Dependencies:" -ForegroundColor Blue
    foreach ($dep in $missingOptional) {
        Write-Host "   • $($dep.Name) - $($dep.Description)" -ForegroundColor Gray
    }
}

# Step 4: Handle missing dependencies
if ($missingRequired.Count -gt 0) {
    Write-Host "`n🔧 Step 4: Resolving Missing Dependencies" -ForegroundColor Cyan
    
    if (-not $CreateMissingResources) {
        Write-Host "`n❌ Required dependencies are missing and -CreateMissingResources was not specified." -ForegroundColor Red
        Write-Host "   Run with -CreateMissingResources to automatically create missing resources." -ForegroundColor Yellow
        Write-Host "   Or use -DryRun to see what would be created." -ForegroundColor Yellow
        exit 1
    }
    
    # Create missing resources in priority order
    foreach ($dep in $missingRequired | Sort-Object Priority) {
        if ($dep.CreateCommand) {
            Write-Host "`n   Creating: $($dep.Name)..." -ForegroundColor Cyan
            
            if ($DryRun) {
                Write-Host "   🔍 DRY RUN: Would execute: $($dep.CreateCommand)" -ForegroundColor Blue
            } else {
                Write-Host "   🔧 Executing: $($dep.CreateCommand)" -ForegroundColor Yellow
                
                try {
                    Invoke-Expression $dep.CreateCommand | Out-Null
                    if ($LASTEXITCODE -eq 0) {
                        Write-Host "   ✅ Successfully created: $($dep.Name)" -ForegroundColor Green
                        $dep.Exists = $true
                    } else {
                        Write-Host "   ❌ Failed to create: $($dep.Name)" -ForegroundColor Red
                        exit 1
                    }
                } catch {
                    Write-Host "   ❌ Error creating $($dep.Name): $($_.Exception.Message)" -ForegroundColor Red
                    exit 1
                }
            }
        } else {
            Write-Host "   ❌ Cannot auto-create: $($dep.Name)" -ForegroundColor Red
            Write-Host "      Manual intervention required: $($dep.Description)" -ForegroundColor Yellow
            exit 1
        }
    }
} else {
    Write-Host "`n✅ Step 4: All required dependencies are available" -ForegroundColor Green
}

# Step 5: Final validation
Write-Host "`n🔍 Step 5: Final Dependency Validation" -ForegroundColor Cyan

if (-not $DryRun) {
    # Re-check all dependencies after creation
    $allValid = $true
    foreach ($depKey in $dependencies.Keys) {
        $dep = $dependencies[$depKey]
        if ($dep.Required -and -not $dep.Exists) {
            try {
                $result = Invoke-Expression "$($dep.CheckCommand) 2>`$null"
                if (-not ($result -and $LASTEXITCODE -eq 0)) {
                    Write-Host "   ❌ $($dep.Name): Still not available after creation" -ForegroundColor Red
                    $allValid = $false
                }
            } catch {
                Write-Host "   ❌ $($dep.Name): Still not available after creation" -ForegroundColor Red
                $allValid = $false
            }
        }
    }
    
    if (-not $allValid) {
        Write-Host "`n❌ Some dependencies are still missing after creation attempts." -ForegroundColor Red
        exit 1
    }
}

# Step 6: Deployment readiness summary
Write-Host "`n🚀 Step 6: Deployment Readiness Summary" -ForegroundColor Green

Write-Host "`n✅ Pre-deployment validation completed successfully!" -ForegroundColor Green
Write-Host "   • Azure CLI: Available and authenticated" -ForegroundColor Gray
Write-Host "   • Subscription: $subscriptionId (accessible)" -ForegroundColor Gray
Write-Host "   • Region: $location (validated)" -ForegroundColor Gray
Write-Host "   • Resource Group: $resourceGroupName (ready)" -ForegroundColor Gray
Write-Host "   • Environment: $environmentName" -ForegroundColor Gray

if ($DryRun) {
    Write-Host "`n🔍 DRY RUN COMPLETE - No actual resources were created" -ForegroundColor Blue
} else {
    Write-Host "`n🎯 READY FOR DEPLOYMENT" -ForegroundColor Magenta
}

Write-Host "`nNext steps:" -ForegroundColor Cyan
Write-Host "  1. Deploy infrastructure: azd up --environment $environmentName" -ForegroundColor White
Write-Host "  2. Or use production script: .\scripts\deploy-production.ps1 -Environment $Environment" -ForegroundColor White
Write-Host "  3. Monitor deployment: azd monitor --environment $environmentName" -ForegroundColor White
