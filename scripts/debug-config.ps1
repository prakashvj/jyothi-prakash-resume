# Debug Configuration Script
Import-Module "$PSScriptRoot\ConfigModule.psm1" -Force

Write-Host "🔍 Debugging Configuration System" -ForegroundColor Cyan

$config = Get-DeploymentConfig -Environment "prod"

if ($config) {
    Write-Host "✅ Configuration loaded" -ForegroundColor Green
    
    # Check environments property
    if ($config.environments) {
        Write-Host "✅ Environments property exists" -ForegroundColor Green
        
        # Check prod environment
        if ($config.environments.prod) {
            Write-Host "✅ Prod environment exists" -ForegroundColor Green
            
            # Check azure property
            if ($config.environments.prod.azure) {
                Write-Host "✅ Azure config exists" -ForegroundColor Green
                
                # Check customDomain
                if ($config.environments.prod.azure.customDomain) {
                    Write-Host "✅ Custom domain config exists" -ForegroundColor Green
                    Write-Host "   Enabled: $($config.environments.prod.azure.customDomain.enabled)" -ForegroundColor White
                    Write-Host "   Friendly Name: $($config.environments.prod.azure.customDomain.friendlyName)" -ForegroundColor White
                    Write-Host "   Full Domain: $($config.environments.prod.azure.customDomain.fullDomain)" -ForegroundColor White
                } else {
                    Write-Host "❌ Custom domain config missing" -ForegroundColor Red
                }
            } else {
                Write-Host "❌ Azure config missing" -ForegroundColor Red
            }
        } else {
            Write-Host "❌ Prod environment missing" -ForegroundColor Red
        }
    } else {
        Write-Host "❌ Environments property missing" -ForegroundColor Red
    }
    
    # Show full structure for debugging
    Write-Host "`n🔍 Full Config Structure:" -ForegroundColor Yellow
    $config | ConvertTo-Json -Depth 10 | Write-Host
    
} else {
    Write-Host "❌ Failed to load configuration" -ForegroundColor Red
}
