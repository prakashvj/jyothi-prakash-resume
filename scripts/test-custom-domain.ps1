# Test Custom Domain Configuration
# Quick test script to verify the configuration works

param(
    [string]$Environment = "prod"
)

Write-Host "🧪 Testing Custom Domain Configuration" -ForegroundColor Cyan
Write-Host "Environment: $Environment" -ForegroundColor Yellow

try {
    # Import the configuration module
    Import-Module "$PSScriptRoot\ConfigModule.psm1" -Force
    
    $config = Get-RawDeploymentConfig
    
    if ($config) {
        Write-Host "✅ Configuration loaded successfully" -ForegroundColor Green
        
        # Access the custom domain configuration
        $envConfig = $config.environments.$Environment
        $customDomainConfig = $envConfig.azure.customDomain
        
        if ($customDomainConfig -and $customDomainConfig.enabled) {
            Write-Host "✅ Custom domain enabled" -ForegroundColor Green
            Write-Host "   Friendly Name: $($customDomainConfig.friendlyName)" -ForegroundColor White
            Write-Host "   Full Domain: $($customDomainConfig.fullDomain)" -ForegroundColor White
            
            # Test the custom domain configuration script
            Write-Host "🔍 Testing custom domain script with WhatIf..." -ForegroundColor Blue
            & "$PSScriptRoot\configure-custom-domain.ps1" -Environment $Environment -WhatIf
            
        } else {
            Write-Host "ℹ️  Custom domain not enabled for this environment" -ForegroundColor Yellow
        }
    } else {
        Write-Host "❌ Failed to load configuration" -ForegroundColor Red
    }
    
} catch {
    Write-Host "❌ Test failed: $($_.Exception.Message)" -ForegroundColor Red
}

Write-Host "🏁 Test completed" -ForegroundColor Cyan
