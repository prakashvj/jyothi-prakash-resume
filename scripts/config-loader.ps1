# Configuration Loader Utility
# This utility helps load and validate configuration from various sources

param(
    [Parameter(Mandatory=$false)]
    [string]$Environment = "dev",
    
    [Parameter(Mandatory=$false)]
    [string]$ConfigPath = "./config",
    
    [Parameter(Mandatory=$false)]
    [switch]$Export,
    
    [Parameter(Mandatory=$false)]
    [switch]$ValidateOnly,
    
    [Parameter(Mandatory=$false)]
    [switch]$ShowAll,
    
    [Parameter(Mandatory=$false)]
    [switch]$ValidateAzureResources
)

function Get-ConfigurationFromSources {
    param([string]$Environment, [string]$ConfigPath)
    
    $config = @{}
    
    # 1. Load from .env.template (defaults and documentation)
    $envTemplate = Join-Path $ConfigPath ".env.template"
    if (Test-Path $envTemplate) {
        Write-Host "Loading template from: $envTemplate" -ForegroundColor Cyan
        Get-Content $envTemplate | ForEach-Object {
            if ($_ -match '^([^#][^=]+)=(.*)$') {
                $key = $matches[1].Trim()
                $value = $matches[2].Trim()
                $config[$key] = $value
                Write-Verbose "Template: $key = $value"
            }
        }
    }
    
    # 2. Load from environments.json (environment-specific)
    $envJsonFile = Join-Path $ConfigPath "environments.json"
    if (Test-Path $envJsonFile) {
        Write-Host "Loading environment config from: $envJsonFile" -ForegroundColor Cyan
        try {
            $envJson = Get-Content $envJsonFile | ConvertFrom-Json
            
            # Function to resolve variable substitution
            function Resolve-ConfigValue {
                param([string]$Value, [object]$SharedConfig)
                
                if ($Value -match '^\$\{shared\.(.+)\}$') {
                    $path = $matches[1] -split '\.'
                    $resolved = $SharedConfig
                    foreach ($segment in $path) {
                        $resolved = $resolved.$segment
                        if (-not $resolved) { break }
                    }
                    return $resolved
                }
                
                # Handle template substitution like ${shared.project.baseResourceName}-RG
                if ($Value -match '\$\{shared\.(.+?)\}') {
                    $templateVar = $matches[0]  # Full match like ${shared.project.baseResourceName}
                    $path = $matches[1] -split '\.'  # path like project.baseResourceName
                    $resolved = $SharedConfig
                    foreach ($segment in $path) {
                        $resolved = $resolved.$segment
                        if (-not $resolved) { break }
                    }
                    if ($resolved) {
                        return $Value -replace [regex]::Escape($templateVar), $resolved
                    }
                }
                
                return $Value
            }
            
            if ($envJson.environments.$Environment) {
                $envSpecific = $envJson.environments.$Environment
                $sharedConfig = $envJson.shared
                
                # Map nested JSON structure to flat environment variables with variable substitution
                if ($envSpecific.azure) {
                    if ($envSpecific.azure.subscriptionId) { 
                        $config["AZURE_SUBSCRIPTION_ID"] = Resolve-ConfigValue $envSpecific.azure.subscriptionId $sharedConfig
                    }
                    if ($envSpecific.azure.tenantId) { 
                        $config["AZURE_TENANT_ID"] = Resolve-ConfigValue $envSpecific.azure.tenantId $sharedConfig
                    }
                    if ($envSpecific.azure.location) { 
                        $config["AZURE_LOCATION"] = Resolve-ConfigValue $envSpecific.azure.location $sharedConfig
                    }
                    if ($envSpecific.azure.environmentName) { 
                        $config["AZURE_ENV_NAME"] = Resolve-ConfigValue $envSpecific.azure.environmentName $sharedConfig
                    }
                }
                
                if ($envSpecific.resources) {
                    if ($envSpecific.resources.resourceGroupName) { 
                        $config["AZURE_RESOURCE_GROUP_NAME"] = Resolve-ConfigValue $envSpecific.resources.resourceGroupName $sharedConfig
                    }
                    if ($envSpecific.resources.staticWebAppName) { 
                        $config["AZURE_STATIC_WEB_APP_NAME"] = Resolve-ConfigValue $envSpecific.resources.staticWebAppName $sharedConfig
                    }
                }
                
                if ($envSpecific.features) {
                    if ($envSpecific.features.enableStagingEnvironments -ne $null) { 
                        $config["ENABLE_STAGING_ENVIRONMENTS"] = $envSpecific.features.enableStagingEnvironments 
                    }
                    if ($envSpecific.features.publicNetworkAccess) { 
                        $config["PUBLIC_NETWORK_ACCESS"] = $envSpecific.features.publicNetworkAccess 
                    }
                    if ($envSpecific.features.allowCustomDomains -ne $null) { 
                        $config["ALLOW_CUSTOM_DOMAINS"] = $envSpecific.features.allowCustomDomains 
                    }
                }
                
                if ($envSpecific.tags) {
                    if ($envSpecific.tags.Environment) { 
                        $config["ENVIRONMENT_TYPE"] = $envSpecific.tags.Environment.ToLower() 
                    }
                    if ($envSpecific.tags.Project) { 
                        $config["PROJECT_NAME"] = Resolve-ConfigValue $envSpecific.tags.Project $sharedConfig
                    }
                    if ($envSpecific.tags.CostCenter) { 
                        $config["COST_CENTER"] = Resolve-ConfigValue $envSpecific.tags.CostCenter $sharedConfig
                    }
                    if ($envSpecific.tags.Owner) { 
                        $config["RESOURCE_OWNER"] = Resolve-ConfigValue $envSpecific.tags.Owner $sharedConfig
                    }
                    if ($envSpecific.tags.Tier) { 
                        $config["APPLICATION_TIER"] = Resolve-ConfigValue $envSpecific.tags.Tier $sharedConfig
                    }
                }
                
                Write-Verbose "Loaded environment-specific configuration for: $Environment"
            }
        }
        catch {
            Write-Warning "Error loading environments.json: $($_.Exception.Message)"
        }
    }
    
    # 3. Load from .env (local overrides)
    $envFile = Join-Path $ConfigPath ".env"
    if (Test-Path $envFile) {
        Write-Host "Loading local config from: $envFile" -ForegroundColor Cyan
        Get-Content $envFile | ForEach-Object {
            if ($_ -match '^([^#][^=]+)=(.*)$') {
                $key = $matches[1].Trim()
                $value = $matches[2].Trim()
                $config[$key] = $value
                Write-Verbose "Local: $key = $value"
            }
        }
    }
    
    # 4. Override with environment variables if they exist
    $configKeys = @($config.Keys)
    $configKeys | ForEach-Object {
        $envValue = [Environment]::GetEnvironmentVariable($_)
        if ($envValue) {
            $config[$_] = $envValue
            Write-Verbose "Environment Variable: $_ = $envValue"
        }
    }
    
    return $config
}

function Show-Configuration {
    param([hashtable]$Config, [bool]$ShowValues = $false)
    
    Write-Host "`n=== Configuration Summary ===" -ForegroundColor Green
    Write-Host "Environment: $Environment" -ForegroundColor Yellow
    Write-Host "Config Path: $ConfigPath" -ForegroundColor Yellow
    Write-Host "Total Variables: $($Config.Count)" -ForegroundColor Yellow
    
    Write-Host "`n--- Azure Configuration ---" -ForegroundColor Cyan
    $azureVars = $Config.GetEnumerator() | Where-Object { $_.Key.StartsWith("AZURE_") } | Sort-Object Key
    foreach ($var in $azureVars) {
        $displayValue = if ($ShowValues) { $var.Value } else { 
            if ($var.Value.Length -gt 0) { "***" } else { "(not set)" }
        }
        Write-Host "  $($var.Key): $displayValue"
    }
    
    Write-Host "`n--- Application Configuration ---" -ForegroundColor Cyan
    $appVars = $Config.GetEnumerator() | Where-Object { $_.Key.StartsWith("APP_") } | Sort-Object Key
    foreach ($var in $appVars) {
        $displayValue = if ($ShowValues) { $var.Value } else { 
            if ($var.Value.Length -gt 0) { "***" } else { "(not set)" }
        }
        Write-Host "  $($var.Key): $displayValue"
    }
    
    if ($ShowAll) {
        Write-Host "`n--- Other Configuration ---" -ForegroundColor Cyan
        $otherVars = $Config.GetEnumerator() | Where-Object { 
            -not $_.Key.StartsWith("AZURE_") -and -not $_.Key.StartsWith("APP_") 
        } | Sort-Object Key
        foreach ($var in $otherVars) {
            $displayValue = if ($ShowValues) { $var.Value } else { 
                if ($var.Value.Length -gt 0) { "***" } else { "(not set)" }
            }
            Write-Host "  $($var.Key): $displayValue"
        }
    }
}

function Test-Configuration {
    param([hashtable]$Config)
    
    Write-Host "`n=== Configuration Validation ===" -ForegroundColor Green
    
    $requiredVars = @(
        "AZURE_SUBSCRIPTION_ID",
        "AZURE_TENANT_ID",
        "AZURE_LOCATION",
        "AZURE_ENV_NAME",
        "AZURE_RESOURCE_GROUP_NAME",
        "AZURE_STATIC_WEB_APP_NAME"
    )
    
    $errors = @()
    $warnings = @()
    
    # Check required variables
    foreach ($var in $requiredVars) {
        if (-not $Config[$var] -or $Config[$var] -eq "") {
            $errors += "Missing required variable: $var"
        }
    }
    
    # Validate GUID format
    $guidPattern = "^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$"
    
    if ($Config["AZURE_SUBSCRIPTION_ID"] -and $Config["AZURE_SUBSCRIPTION_ID"] -notmatch $guidPattern) {
        $errors += "Invalid AZURE_SUBSCRIPTION_ID format (must be GUID)"
    }
    
    if ($Config["AZURE_TENANT_ID"] -and $Config["AZURE_TENANT_ID"] -notmatch $guidPattern) {
        $errors += "Invalid AZURE_TENANT_ID format (must be GUID)"
    }
    
    # Validate naming conventions
    if ($Config["AZURE_RESOURCE_GROUP_NAME"] -and -not $Config["AZURE_RESOURCE_GROUP_NAME"].EndsWith("-RG")) {
        $warnings += "Resource group name should end with '-RG' suffix"
    }
    
    if ($Config["AZURE_STATIC_WEB_APP_NAME"] -and -not $Config["AZURE_STATIC_WEB_APP_NAME"].EndsWith("-WebApp")) {
        $warnings += "Static web app name should end with '-WebApp' suffix"
    }
    
    # Show results
    if ($errors.Count -eq 0) {
        Write-Host "✅ Configuration validation passed!" -ForegroundColor Green
    } else {
        Write-Host "❌ Configuration validation failed!" -ForegroundColor Red
        foreach ($configError in $errors) {
            Write-Host "  ERROR: $configError" -ForegroundColor Red
        }
    }
    
    if ($warnings.Count -gt 0) {
        Write-Host "`nWarnings:" -ForegroundColor Yellow
        foreach ($warning in $warnings) {
            Write-Host "  WARNING: $warning" -ForegroundColor Yellow
        }
    }
    
    return $errors.Count -eq 0
}

function Test-AzureResourcesExist {
    param([hashtable]$Config)
    
    Write-Host "`n=== Azure Resources Validation ===" -ForegroundColor Green
    
    $errors = @()
    $warnings = @()
    
    try {
        # Check if Azure CLI is available
        $azVersion = az version 2>$null
        if (-not $azVersion) {
            $errors += "Azure CLI not found. Please install Azure CLI."
            return @{
                Success = $false
                Errors = $errors
                Warnings = $warnings
            }
        }
        
        # Check if logged in to Azure
        $account = az account show 2>$null | ConvertFrom-Json
        if (-not $account) {
            $errors += "Not logged in to Azure. Please run 'az login'."
            return @{
                Success = $false
                Errors = $errors
                Warnings = $warnings
            }
        }
        
        Write-Host "✅ Azure CLI available and authenticated" -ForegroundColor Green
        Write-Host "   Current account: $($account.user.name)" -ForegroundColor Gray
        Write-Host "   Current subscription: $($account.name)" -ForegroundColor Gray
        
        # Validate subscription access
        if ($Config["AZURE_SUBSCRIPTION_ID"]) {
            $subscription = az account show --subscription $Config["AZURE_SUBSCRIPTION_ID"] 2>$null | ConvertFrom-Json
            if (-not $subscription) {
                $errors += "Cannot access subscription: $($Config['AZURE_SUBSCRIPTION_ID']). Check permissions."
            } else {
                Write-Host "✅ Subscription access validated: $($subscription.name)" -ForegroundColor Green
            }
        }
        
        # Check if resource group exists
        if ($Config["AZURE_RESOURCE_GROUP_NAME"] -and $Config["AZURE_SUBSCRIPTION_ID"]) {
            Write-Host "Checking Resource Group: $($Config['AZURE_RESOURCE_GROUP_NAME'])..." -ForegroundColor Cyan
            
            $rg = az group show --name $Config["AZURE_RESOURCE_GROUP_NAME"] --subscription $Config["AZURE_SUBSCRIPTION_ID"] 2>$null | ConvertFrom-Json
            if (-not $rg) {
                $warnings += "Resource Group '$($Config['AZURE_RESOURCE_GROUP_NAME'])' does not exist. It will be created during deployment."
                Write-Host "⚠️  Resource Group '$($Config['AZURE_RESOURCE_GROUP_NAME'])' does not exist" -ForegroundColor Yellow
            } else {
                Write-Host "✅ Resource Group exists: $($rg.name) in $($rg.location)" -ForegroundColor Green
                
                # Validate region matches
                if ($Config["AZURE_LOCATION"] -and $rg.location -ne $Config["AZURE_LOCATION"]) {
                    $warnings += "Resource Group location ($($rg.location)) differs from configured location ($($Config['AZURE_LOCATION']))"
                }
            }
        }
        
        # Check if Static Web App already exists
        if ($Config["AZURE_STATIC_WEB_APP_NAME"] -and $Config["AZURE_RESOURCE_GROUP_NAME"] -and $Config["AZURE_SUBSCRIPTION_ID"]) {
            Write-Host "Checking Static Web App: $($Config['AZURE_STATIC_WEB_APP_NAME'])..." -ForegroundColor Cyan
            
            $staticWebApp = az staticwebapp show --name $Config["AZURE_STATIC_WEB_APP_NAME"] --resource-group $Config["AZURE_RESOURCE_GROUP_NAME"] --subscription $Config["AZURE_SUBSCRIPTION_ID"] 2>$null | ConvertFrom-Json
            if ($staticWebApp) {
                Write-Host "✅ Static Web App exists: $($staticWebApp.name)" -ForegroundColor Green
                Write-Host "   Status: $($staticWebApp.repositoryUrl)" -ForegroundColor Gray
                Write-Host "   Default hostname: $($staticWebApp.defaultHostname)" -ForegroundColor Gray
            } else {
                Write-Host "ℹ️  Static Web App '$($Config['AZURE_STATIC_WEB_APP_NAME'])' does not exist. It will be created during deployment." -ForegroundColor Blue
            }
        }
        
        # Validate region availability
        if ($Config["AZURE_LOCATION"]) {
            Write-Host "Validating region availability: $($Config['AZURE_LOCATION'])..." -ForegroundColor Cyan
            
            # Simple validation by trying to get the specific location
            $locationTest = az account list-locations --query "[?name=='$($Config["AZURE_LOCATION"])'].displayName" --output tsv
            
            if ($locationTest -and $locationTest.Trim() -ne "") {
                Write-Host "✅ Region validated: $($locationTest.Trim())" -ForegroundColor Green
            } else {
                $errors += "Invalid Azure region: $($Config['AZURE_LOCATION']). Please verify the region name."
            }
        }
        
    } catch {
        $errors += "Error during Azure resources validation: $($_.Exception.Message)"
    }
    
    return @{
        Success = $errors.Count -eq 0
        Errors = $errors
        Warnings = $warnings
    }
}

function Export-EnvironmentVariables {
    param([hashtable]$Config)
    
    Write-Host "`n=== Exporting Environment Variables ===" -ForegroundColor Green
    
    foreach ($key in $Config.Keys) {
        if ($Config[$key] -and $Config[$key] -ne "") {
            [Environment]::SetEnvironmentVariable($key, $Config[$key], "Process")
            Write-Host "Exported: $key" -ForegroundColor Cyan
        }
    }
    
    Write-Host "Environment variables exported to current PowerShell session." -ForegroundColor Green
    Write-Host "Note: These will only be available in this session." -ForegroundColor Yellow
}

# Main execution
try {
    Write-Host "=== Configuration Loader ===" -ForegroundColor Magenta
    
    # Load configuration
    $config = Get-ConfigurationFromSources -Environment $Environment -ConfigPath $ConfigPath
    
    if ($config.Count -eq 0) {
        Write-Host "No configuration found. Please check your config files." -ForegroundColor Red
        exit 1
    }
    
    # Show configuration
    Show-Configuration -Config $config -ShowValues:$ShowAll
    
    # Validate configuration
    $isValid = Test-Configuration -Config $config
    
    # Validate Azure resources if requested
    $azureValidationResult = $null
    if ($ValidateAzureResources) {
        $azureValidationResult = Test-AzureResourcesExist -Config $config
        
        # Show Azure validation results
        if ($azureValidationResult.Errors.Count -gt 0) {
            Write-Host "`nAzure Validation Errors:" -ForegroundColor Red
            foreach ($error in $azureValidationResult.Errors) {
                Write-Host "  ERROR: $error" -ForegroundColor Red
            }
        }
        
        if ($azureValidationResult.Warnings.Count -gt 0) {
            Write-Host "`nAzure Validation Warnings:" -ForegroundColor Yellow
            foreach ($warning in $azureValidationResult.Warnings) {
                Write-Host "  WARNING: $warning" -ForegroundColor Yellow
            }
        }
        
        if ($azureValidationResult.Success) {
            Write-Host "`n✅ Azure resources validation passed!" -ForegroundColor Green
        } else {
            Write-Host "`n❌ Azure resources validation failed!" -ForegroundColor Red
        }
    }
    
    if ($ValidateOnly) {
        $overallSuccess = $isValid -and ($azureValidationResult -eq $null -or $azureValidationResult.Success)
        exit $(if ($overallSuccess) { 0 } else { 1 })
    }
    
    # Export if requested
    if ($Export) {
        Export-EnvironmentVariables -Config $config
    }
    
    Write-Host "`n=== Configuration Loading Completed ===" -ForegroundColor Magenta
    
} catch {
    Write-Host "Error loading configuration: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}
