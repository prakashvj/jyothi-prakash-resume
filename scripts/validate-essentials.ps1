# Essential Pre-Deployment Validation Script
# Lightweight validation script with the most critical checks

param(
    [switch]$Detailed,
    [switch]$QuickCheck,
    [string]$Environment = "prod",
    [string]$ConfigPath = "./config"
)

# Import configuration module
Import-Module "$PSScriptRoot\ConfigModule.psm1" -Force

function Write-ValidationLog {
    param([string]$Message, [string]$Level = "INFO", [string]$Check = "")
    $timestamp = Get-Date -Format "HH:mm:ss"
    $prefix = if ($Check) { "[$Check] " } else { "" }
    $color = switch ($Level) {
        "ERROR" { "Red" }
        "WARN" { "Yellow" }
        "SUCCESS" { "Green" }
        "INFO" { "Cyan" }
        default { "White" }
    }
    Write-Host "[$timestamp] $prefix$Message" -ForegroundColor $color
}

function Test-EssentialDependencies {
    Write-ValidationLog "Checking essential dependencies..." "INFO" "DEPS"
    $allValid = $true
    
    # Azure CLI
    try {
        $null = az version 2>$null
        if ($LASTEXITCODE -eq 0) {
            Write-ValidationLog "✓ Azure CLI available" "SUCCESS" "DEPS"
        } else {
            Write-ValidationLog "✗ Azure CLI not found" "ERROR" "DEPS"
            $allValid = $false
        }
    } catch {
        Write-ValidationLog "✗ Azure CLI not found" "ERROR" "DEPS"
        $allValid = $false
    }
    
    # Azure authentication
    try {
        $account = az account show --query "name" --output tsv 2>$null
        if ($account) {
            Write-ValidationLog "✓ Azure authenticated as: $account" "SUCCESS" "DEPS"
        } else {
            Write-ValidationLog "✗ Not authenticated to Azure" "ERROR" "DEPS"
            $allValid = $false
        }
    } catch {
        Write-ValidationLog "✗ Azure authentication failed" "ERROR" "DEPS"
        $allValid = $false
    }
    
    # AZD CLI (only if not quick check)
    if (-not $QuickCheck) {
        try {
            $null = azd version 2>$null
            if ($LASTEXITCODE -eq 0) {
                Write-ValidationLog "✓ Azure Developer CLI available" "SUCCESS" "DEPS"
            } else {
                Write-ValidationLog "✗ Azure Developer CLI not found" "ERROR" "DEPS"
                $allValid = $false
            }
        } catch {
            Write-ValidationLog "✗ Azure Developer CLI not found" "ERROR" "DEPS"
            $allValid = $false
        }
    }
    
    return $allValid
}

function Test-SourceFiles {
    Write-ValidationLog "Validating source files..." "INFO" "FILES"
    $allValid = $true
    
    $requiredFiles = @(
        @{ Path = "src/index.html"; Type = "HTML" },
        @{ Path = "src/css/style.css"; Type = "CSS" },
        @{ Path = "azure.yaml"; Type = "Config" }
    )
    
    if (-not $QuickCheck) {
        $requiredFiles += @{ Path = "infra/main.bicep"; Type = "Infrastructure" }
    }
    
    foreach ($file in $requiredFiles) {
        if (Test-Path $file.Path) {
            Write-ValidationLog "✓ Found: $($file.Path)" "SUCCESS" "FILES"
            
            # Basic content validation
            if ($file.Type -eq "HTML") {
                $content = Get-Content $file.Path -Raw
                if ($content -like "*<html*" -and $content -like "*</html>*") {
                    Write-ValidationLog "✓ HTML structure valid" "SUCCESS" "FILES"
                } else {
                    Write-ValidationLog "⚠ HTML structure questionable" "WARN" "FILES"
                }
            }
        } else {
            Write-ValidationLog "✗ Missing: $($file.Path)" "ERROR" "FILES"
            $allValid = $false
        }
    }
    
    return $allValid
}

function Test-AzureResources {
    if ($QuickCheck) { return $true }
    
    Write-ValidationLog "Checking Azure resources..." "INFO" "AZURE"
    
    # Load configuration for resource names
    $config = Get-DeploymentConfig -Environment $Environment -ConfigPath $ConfigPath
    $azureResources = Get-AzureResourceNames -Config $config
    
    try {
        # Check Static Web App
        $swa = az staticwebapp show --name $azureResources.StaticWebApp --resource-group $azureResources.ResourceGroup --query "{ name: name, defaultHostname: defaultHostname }" --output json 2>$null | ConvertFrom-Json
        if ($swa) {
            Write-ValidationLog "✓ Static Web App exists: $($swa.name)" "SUCCESS" "AZURE"
            Write-ValidationLog "✓ URL: https://$($swa.defaultHostname)" "SUCCESS" "AZURE"
        } else {
            Write-ValidationLog "⚠ Static Web App not found (will be created)" "WARN" "AZURE"
        }
    } catch {
        Write-ValidationLog "⚠ Could not check Azure resources" "WARN" "AZURE"
    }
    
    return $true
}

# Main validation execution
Write-ValidationLog "=== Essential Pre-Deployment Validation ===" "INFO"
if ($QuickCheck) {
    Write-ValidationLog "Running quick validation checks..." "INFO"
} else {
    Write-ValidationLog "Running comprehensive validation checks..." "INFO"
}

$validationResults = @{
    Dependencies = Test-EssentialDependencies
    SourceFiles = Test-SourceFiles
    AzureResources = Test-AzureResources
}

Write-ValidationLog "" "INFO"
Write-ValidationLog "=== Validation Summary ===" "INFO"

$allPassed = $true
foreach ($check in $validationResults.GetEnumerator()) {
    $status = if ($check.Value) { "PASS" } else { "FAIL" }
    $color = if ($check.Value) { "SUCCESS" } else { "ERROR" }
    
    Write-ValidationLog "$($check.Key): $status" $color
    
    if (-not $check.Value) {
        $allPassed = $false
    }
}

Write-ValidationLog "" "INFO"

if ($allPassed) {
    Write-ValidationLog "🎉 All essential validation checks passed!" "SUCCESS"
    exit 0
} else {
    Write-ValidationLog "❌ Some validation checks failed." "ERROR"
    if ($QuickCheck) {
        Write-ValidationLog "Run without -QuickCheck for detailed validation" "INFO"
    }
    exit 1
}
