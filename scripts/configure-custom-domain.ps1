# Configure Custom Domain for Azure Static Web App
# Part of the centralized deployment system

param(
    [Parameter(Mandatory=$true)]
    [string]$Environment = "prod",
    
    [Parameter(Mandatory=$false)]
    [switch]$WhatIf
)

# Import configuration module
Import-Module "$PSScriptRoot\ConfigModule.psm1" -Force

try {
    Write-Host "🌐 Configuring Custom Domain for Environment: $Environment" -ForegroundColor Cyan
    
    # Load environment configuration
    $config = Get-RawDeploymentConfig
    
    if (-not $config) {
        throw "Failed to load configuration"
    }
    
    # Access the environment-specific configuration
    $envConfig = $config.environments.$Environment
    if (-not $envConfig) {
        throw "Environment '$Environment' not found in configuration"
    }
    
    # Check if custom domain is enabled
    if (-not $envConfig.azure.customDomain.enabled) {
        Write-Host "ℹ️  Custom domain not enabled for $Environment environment" -ForegroundColor Yellow
        return
    }
    
    $resourceGroup = $envConfig.azure.resourceGroup
    $staticWebAppName = $envConfig.azure.staticWebAppName
    $friendlyName = $envConfig.azure.customDomain.friendlyName
    $domainType = $envConfig.azure.customDomain.domainType
    
    Write-Host "📋 Configuration Details:" -ForegroundColor Green
    Write-Host "   Resource Group: $resourceGroup"
    Write-Host "   Static Web App: $staticWebAppName"
    Write-Host "   Friendly Name: $friendlyName"
    Write-Host "   Domain Type: $domainType"
    
    if ($domainType -eq "azurestaticapps") {
        $customDomain = "$friendlyName.azurestaticapps.net"
        Write-Host "   Target Domain: $customDomain"
        
        if ($WhatIf) {
            Write-Host "🔍 WHAT-IF: Would configure custom domain: $customDomain" -ForegroundColor Yellow
            return
        }
        
        # Check if domain already exists
        Write-Host "🔍 Checking existing custom domains..." -ForegroundColor Blue
        
        $existingDomains = az staticwebapp hostname list --name $staticWebAppName --resource-group $resourceGroup --output json 2>$null
        
        if ($existingDomains) {
            $domains = $existingDomains | ConvertFrom-Json
            $existingDomain = $domains | Where-Object { $_.name -eq $customDomain }
            
            if ($existingDomain) {
                Write-Host "✅ Custom domain already configured: $customDomain" -ForegroundColor Green
                Write-Host "   Status: $($existingDomain.status)" -ForegroundColor Green
                return
            }
        }
        
        # Configure the custom domain
        Write-Host "🚀 Configuring custom domain: $customDomain" -ForegroundColor Green
        
        $result = az staticwebapp hostname set --name $staticWebAppName --resource-group $resourceGroup --hostname $customDomain --output json 2>&1
        
        if ($LASTEXITCODE -eq 0) {
            Write-Host "✅ Successfully configured custom domain: $customDomain" -ForegroundColor Green
            
            # Update configuration with the actual domain
            Write-Host "📝 Domain will be available at: https://$customDomain" -ForegroundColor Cyan
            
            # Verify SSL certificate
            Start-Sleep -Seconds 5
            Write-Host "🔐 Verifying SSL certificate configuration..." -ForegroundColor Blue
            
            $domainInfo = az staticwebapp hostname show --name $staticWebAppName --resource-group $resourceGroup --hostname $customDomain --output json 2>$null
            
            if ($domainInfo) {
                $domain = $domainInfo | ConvertFrom-Json
                Write-Host "   SSL Status: $($domain.sslState)" -ForegroundColor Green
            }
            
        } else {
            Write-Host "❌ Failed to configure custom domain" -ForegroundColor Red
            Write-Host "Error: $result" -ForegroundColor Red
            exit 1
        }
    }
    else {
        Write-Host "⚠️  Domain type '$domainType' not yet supported in this script" -ForegroundColor Yellow
        Write-Host "   Supported types: azurestaticapps" -ForegroundColor Yellow
    }
    
} catch {
    Write-Host "❌ Error configuring custom domain: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}

Write-Host "🎉 Custom domain configuration completed!" -ForegroundColor Green
