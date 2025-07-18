# Pre-deployment Validation Script
# Performs comprehensive checks before production deployment

param(
    [Parameter(Mandatory=$false)]
    [string]$Environment = "dev",
    
    [Parameter(Mandatory=$false)]
    [string]$ConfigPath = "./config",
    
    [Parameter(Mandatory=$false)]
    [switch]$Detailed
)

$ErrorActionPreference = "Stop"

function Write-ValidationLog {
    param(
        [string]$Message, 
        [string]$Level = "INFO",
        [string]$Check = ""
    )
    
    $timestamp = Get-Date -Format "HH:mm:ss"
    $prefix = if ($Check) { "[$Check] " } else { "" }
    
    $color = switch ($Level) {
        "ERROR" { "Red" }
        "WARN" { "Yellow" }
        "SUCCESS" { "Green" }
        "INFO" { "Cyan" }
        "DEBUG" { "Gray" }
        default { "White" }
    }
    
    Write-Host "[$timestamp] $prefix$Message" -ForegroundColor $color
}

function Test-AzureAuth {
    Write-ValidationLog "Checking Azure authentication..." "INFO" "AUTH"
    
    try {
        $account = az account show --query "{ name: name, id: id, tenantId: tenantId }" --output json 2>$null | ConvertFrom-Json
        if ($account) {
            Write-ValidationLog "✓ Authenticated as: $($account.name)" "SUCCESS" "AUTH"
            Write-ValidationLog "✓ Subscription: $($account.id)" "SUCCESS" "AUTH"
            Write-ValidationLog "✓ Tenant: $($account.tenantId)" "SUCCESS" "AUTH"
            return $true
        }
    }
    catch {
        Write-ValidationLog "✗ Azure authentication failed" "ERROR" "AUTH"
        Write-ValidationLog "Run 'az login' to authenticate" "WARN" "AUTH"
        return $false
    }
    
    return $false
}

function Test-AzdAuth {
    Write-ValidationLog "Checking Azure Developer CLI authentication..." "INFO" "AZD"
    
    try {
        $azdStatus = azd auth login --check-status 2>$null
        if ($LASTEXITCODE -eq 0) {
            Write-ValidationLog "✓ AZD authenticated successfully" "SUCCESS" "AZD"
            return $true
        }
    }
    catch {
        Write-ValidationLog "✗ AZD authentication failed" "ERROR" "AZD"
        Write-ValidationLog "Run 'azd auth login' to authenticate" "WARN" "AZD"
        return $false
    }
    
    return $false
}

function Test-Configuration {
    param([string]$Environment, [string]$ConfigPath)
    
    Write-ValidationLog "Validating configuration for environment: $Environment" "INFO" "CONFIG"
    
    $requiredFiles = @(
        ".env",
        "config.json",
        "deployment.yaml"
    )
    
    $optionalFiles = @(
        "settings.ini"
    )
    
    $configValid = $true
    
    foreach ($file in $requiredFiles) {
        $filePath = Join-Path $ConfigPath $file
        if (Test-Path $filePath) {
            Write-ValidationLog "✓ Found: $file" "SUCCESS" "CONFIG"
            
            # Validate file content
            try {
                switch -Regex ($file) {
                    "\.json$" {
                        $content = Get-Content $filePath -Raw | ConvertFrom-Json
                        Write-ValidationLog "✓ Valid JSON: $file" "SUCCESS" "CONFIG"
                    }
                    "\.yaml$|\.yml$" {
                        # Basic YAML validation (PowerShell doesn't have built-in YAML support)
                        $content = Get-Content $filePath
                        if ($content -and $content.Count -gt 0) {
                            Write-ValidationLog "✓ Valid YAML: $file" "SUCCESS" "CONFIG"
                        }
                    }
                    default {
                        $content = Get-Content $filePath
                        if ($content) {
                            Write-ValidationLog "✓ Readable: $file" "SUCCESS" "CONFIG"
                        }
                    }
                }
            }
            catch {
                Write-ValidationLog "✗ Invalid format: $file - $($_.Exception.Message)" "ERROR" "CONFIG"
                $configValid = $false
            }
        }
        else {
            Write-ValidationLog "✗ Missing: $file" "ERROR" "CONFIG"
            $configValid = $false
        }
    }
    
    # Check optional files
    foreach ($file in $optionalFiles) {
        $filePath = Join-Path $ConfigPath $file
        if (Test-Path $filePath) {
            Write-ValidationLog "✓ Found optional: $file" "SUCCESS" "CONFIG"
        } else {
            Write-ValidationLog "ℹ Optional file not found: $file" "INFO" "CONFIG"
        }
    }
    
    # Validate required environment variables
    $envVars = @()
    $envFile = Join-Path $ConfigPath ".env"
    if (Test-Path $envFile) {
        $envContent = Get-Content $envFile
        foreach ($line in $envContent) {
            if ($line -match '^([^#][^=]+)=(.*)$') {
                $envVars += $matches[1].Trim()
            }
        }
    }
    
    $requiredVars = @(
        "AZURE_SUBSCRIPTION_ID",
        "AZURE_TENANT_ID", 
        "AZURE_LOCATION",
        "AZURE_ENV_NAME",
        "AZURE_RESOURCE_GROUP_NAME",
        "AZURE_STATIC_WEB_APP_NAME"
    )
    
    foreach ($var in $requiredVars) {
        if ($var -in $envVars) {
            Write-ValidationLog "✓ Environment variable: $var" "SUCCESS" "CONFIG"
        }
        else {
            Write-ValidationLog "✗ Missing environment variable: $var" "ERROR" "CONFIG"
            $configValid = $false
        }
    }
    
    return $configValid
}

function Test-SourceCode {
    Write-ValidationLog "Validating source code..." "INFO" "SOURCE"
    
    $requiredFiles = @(
        @{ Path = "src/index.html"; Type = "HTML" },
        @{ Path = "src/css/style.css"; Type = "CSS" },
        @{ Path = "azure.yaml"; Type = "Azure Config" },
        @{ Path = "package.json"; Type = "Package Config" }
    )
    
    $optionalFiles = @(
        @{ Path = "src/js/main.js"; Type = "JavaScript" }
    )
    
    $sourceValid = $true
    
    foreach ($file in $requiredFiles) {
        if (Test-Path $file.Path) {
            Write-ValidationLog "✓ Found: $($file.Path)" "SUCCESS" "SOURCE"
            
            # Basic content validation
            try {
                $content = Get-Content $file.Path -Raw
                if ($content -and $content.Length -gt 0) {
                    Write-ValidationLog "✓ Non-empty: $($file.Path)" "SUCCESS" "SOURCE"
                    
                    # Type-specific validation
                    switch ($file.Type) {
                        "HTML" {
                            if ($content -like "*<html*" -and $content -like "*</html>*") {
                                Write-ValidationLog "✓ Valid HTML structure: $($file.Path)" "SUCCESS" "SOURCE"
                            } else {
                                Write-ValidationLog "⚠ HTML structure questionable: $($file.Path)" "WARN" "SOURCE"
                            }
                        }
                        "Package Config" {
                            $packageJson = $content | ConvertFrom-Json
                            if ($packageJson.name) {
                                Write-ValidationLog "✓ Valid package.json: $($file.Path)" "SUCCESS" "SOURCE"
                            }
                        }
                    }
                }
                else {
                    Write-ValidationLog "⚠ Empty file: $($file.Path)" "WARN" "SOURCE"
                }
            }
            catch {
                Write-ValidationLog "✗ Error reading: $($file.Path) - $($_.Exception.Message)" "ERROR" "SOURCE"
                $sourceValid = $false
            }
        }
        else {
            Write-ValidationLog "✗ Missing: $($file.Path)" "ERROR" "SOURCE"
            $sourceValid = $false
        }
    }
    
    # Check optional files
    foreach ($file in $optionalFiles) {
        if (Test-Path $file.Path) {
            Write-ValidationLog "✓ Found optional: $($file.Path)" "SUCCESS" "SOURCE"
            
            # Basic content validation for optional files
            try {
                $content = Get-Content $file.Path -Raw
                if ($content -and $content.Length -gt 0) {
                    Write-ValidationLog "✓ Non-empty optional: $($file.Path)" "SUCCESS" "SOURCE"
                } else {
                    Write-ValidationLog "ℹ Optional file is empty: $($file.Path)" "INFO" "SOURCE"
                }
            }
            catch {
                Write-ValidationLog "⚠ Error reading optional file: $($file.Path)" "WARN" "SOURCE"
            }
        } else {
            Write-ValidationLog "ℹ Optional file not found: $($file.Path)" "INFO" "SOURCE"
        }
    }
    
    return $sourceValid
}

function Test-InfrastructureCode {
    Write-ValidationLog "Validating infrastructure code..." "INFO" "INFRA"
    
    $infraFiles = @(
        @{ Path = "infra/main.bicep"; Type = "Bicep" },
        @{ Path = "infra/staticwebapp.bicep"; Type = "Bicep" },
        @{ Path = "infra/main.parameters.json"; Type = "Parameters" }
    )
    
    $infraValid = $true
    
    foreach ($file in $infraFiles) {
        if (Test-Path $file.Path) {
            Write-ValidationLog "✓ Found: $($file.Path)" "SUCCESS" "INFRA"
            
            try {
                $content = Get-Content $file.Path -Raw
                if ($content) {
                    # Basic Bicep validation
                    if ($file.Type -eq "Bicep") {
                        if ($content -like "*resource*" -or $content -like "*module*") {
                            Write-ValidationLog "✓ Valid Bicep syntax: $($file.Path)" "SUCCESS" "INFRA"
                        } else {
                            Write-ValidationLog "⚠ No resources found in: $($file.Path)" "WARN" "INFRA"
                        }
                    }
                    
                    # Parameters validation
                    if ($file.Type -eq "Parameters") {
                        $params = $content | ConvertFrom-Json
                        if ($params.parameters) {
                            Write-ValidationLog "✓ Valid parameters file: $($file.Path)" "SUCCESS" "INFRA"
                        }
                    }
                }
            }
            catch {
                Write-ValidationLog "✗ Error validating: $($file.Path) - $($_.Exception.Message)" "ERROR" "INFRA"
                $infraValid = $false
            }
        }
        else {
            Write-ValidationLog "✗ Missing: $($file.Path)" "ERROR" "INFRA"
            $infraValid = $false
        }
    }
    
    return $infraValid
}

function Test-AzureResources {
    param([string]$ConfigPath)
    
    Write-ValidationLog "Checking existing Azure resources..." "INFO" "AZURE"
    
    # Load configuration
    $envFile = Join-Path $ConfigPath ".env"
    $config = @{}
    
    if (Test-Path $envFile) {
        Get-Content $envFile | ForEach-Object {
            if ($_ -match '^([^#][^=]+)=(.*)$') {
                $key = $matches[1].Trim()
                $value = $matches[2].Trim()
                $config[$key] = $value
            }
        }
    }
    
    if (-not $config["AZURE_RESOURCE_GROUP_NAME"]) {
        Write-ValidationLog "⚠ Cannot check resources - missing resource group name" "WARN" "AZURE"
        return $true
    }
    
    $resourceGroup = $config["AZURE_RESOURCE_GROUP_NAME"]
    $staticWebAppName = $config["AZURE_STATIC_WEB_APP_NAME"]
    
    try {
        # Check resource group
        $rg = az group show --name $resourceGroup --query "{ name: name, location: location, provisioningState: properties.provisioningState }" --output json 2>$null | ConvertFrom-Json
        if ($rg) {
            Write-ValidationLog "✓ Resource Group exists: $($rg.name) in $($rg.location)" "SUCCESS" "AZURE"
        } else {
            Write-ValidationLog "⚠ Resource Group not found: $resourceGroup" "WARN" "AZURE"
        }
        
        # Check Static Web App
        if ($staticWebAppName) {
            $swa = az staticwebapp show --name $staticWebAppName --resource-group $resourceGroup --query "{ name: name, defaultHostname: defaultHostname, location: location }" --output json 2>$null | ConvertFrom-Json
            if ($swa) {
                Write-ValidationLog "✓ Static Web App exists: $($swa.name)" "SUCCESS" "AZURE"
                Write-ValidationLog "✓ URL: https://$($swa.defaultHostname)" "SUCCESS" "AZURE"
            } else {
                Write-ValidationLog "⚠ Static Web App not found: $staticWebAppName" "WARN" "AZURE"
            }
        }
        
    }
    catch {
        Write-ValidationLog "⚠ Error checking Azure resources: $($_.Exception.Message)" "WARN" "AZURE"
    }
    
    return $true
}

function Test-Dependencies {
    Write-ValidationLog "Checking dependencies..." "INFO" "DEPS"
    
    $dependencies = @(
        @{ Name = "Azure CLI"; Command = "az version" },
        @{ Name = "Azure Developer CLI"; Command = "azd version" },
        @{ Name = "PowerShell"; Command = "Get-Host | Select-Object Version" }
    )
    
    $depsValid = $true
    
    foreach ($dep in $dependencies) {
        try {
            $null = Invoke-Expression $dep.Command 2>$null
            if ($LASTEXITCODE -eq 0) {
                Write-ValidationLog "✓ $($dep.Name) is available" "SUCCESS" "DEPS"
            } else {
                Write-ValidationLog "✗ $($dep.Name) is not available" "ERROR" "DEPS"
                $depsValid = $false
            }
        }
        catch {
            Write-ValidationLog "✗ $($dep.Name) check failed" "ERROR" "DEPS"
            $depsValid = $false
        }
    }
    
    return $depsValid
}

# Main validation execution
try {
    Write-ValidationLog "=== Pre-Deployment Validation Started ===" "INFO"
    Write-ValidationLog "Environment: $Environment" "INFO"
    Write-ValidationLog "Config Path: $ConfigPath" "INFO"
    
    $validationResults = @{
        Authentication = Test-AzureAuth
        AzdAuth = Test-AzdAuth
        Configuration = Test-Configuration -Environment $Environment -ConfigPath $ConfigPath
        SourceCode = Test-SourceCode
        Infrastructure = Test-InfrastructureCode
        Dependencies = Test-Dependencies
        AzureResources = Test-AzureResources -ConfigPath $ConfigPath
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
        Write-ValidationLog "🎉 All validation checks passed! Ready for deployment." "SUCCESS"
        Write-ValidationLog "You can now run: .\scripts\deploy-production.ps1 -Environment $Environment" "INFO"
        exit 0
    } else {
        Write-ValidationLog "❌ Some validation checks failed. Please fix the issues before deployment." "ERROR"
        exit 1
    }
    
} catch {
    Write-ValidationLog "Validation script failed: $($_.Exception.Message)" "ERROR"
    exit 1
}
