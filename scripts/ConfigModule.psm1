# Centralized Configuration Management
# This module provides a unified way to load configuration from multiple sources
# Priority: Environment Variables > .env file > environments.json > config.json

function Get-DeploymentConfig {
    param(
        [Parameter(Mandatory=$true)]
        [string]$Environment,
        
        [Parameter(Mandatory=$false)]
        [string]$ConfigPath = "./config"
    )
    
    $config = @{}
    
    Write-Verbose "Loading configuration for environment: $Environment"
    
    # 1. Load base configuration from environments.json
    $envJsonFile = Join-Path $ConfigPath "environments.json"
    if (Test-Path $envJsonFile) {
        try {
            $envJson = Get-Content $envJsonFile | ConvertFrom-Json
            
            if ($envJson.environments.$Environment) {
                $envConfig = $envJson.environments.$Environment
                
                # Azure Configuration
                $config["AZURE_SUBSCRIPTION_ID"] = Resolve-ConfigValue $envConfig.azure.subscriptionId
                $config["AZURE_TENANT_ID"] = Resolve-ConfigValue $envConfig.azure.tenantId
                $config["AZURE_LOCATION"] = $envConfig.azure.location
                $config["AZURE_ENV_NAME"] = $envConfig.azure.environmentName
                $config["AZURE_RESOURCE_GROUP_NAME"] = $envConfig.azure.resourceGroup
                $config["AZURE_STATIC_WEB_APP_NAME"] = $envConfig.azure.staticWebAppName
                
                # Deployment Configuration
                $config["DEPLOYMENT_ENVIRONMENT"] = $envConfig.deployment.environment
                $config["DEPLOYMENT_OUTPUT_PATH"] = $envConfig.deployment.outputPath
                $config["DEPLOYMENT_SKIP_BUILD"] = $envConfig.deployment.skipBuild
                
                # Feature Flags
                $config["ENABLE_APPLICATION_INSIGHTS"] = $envConfig.features.enableApplicationInsights
                $config["ENABLE_SSL"] = $envConfig.features.enableSSL
                $config["ENABLE_STAGING_SLOTS"] = $envConfig.features.enableStagingSlots
                $config["ALLOW_CUSTOM_DOMAINS"] = $envConfig.features.enableCustomDomains
                
                # Monitoring
                $config["ENABLE_HEALTH_CHECKS"] = $envConfig.monitoring.healthChecksEnabled
                $config["LOGGING_LEVEL"] = $envConfig.monitoring.loggingLevel
                
                # Tags
                $config["ENVIRONMENT_TYPE"] = $envConfig.tags.Environment
                $config["PROJECT_NAME"] = $envConfig.tags.Project
                $config["RESOURCE_OWNER"] = $envConfig.tags.Owner
                $config["COST_CENTER"] = $envConfig.tags.CostCenter
                
                Write-Verbose "Loaded environment-specific configuration from environments.json"
            }
            
            # Load shared configuration
            if ($envJson.shared) {
                $shared = $envJson.shared
                $config["GITHUB_BRANCH"] = Resolve-ConfigValue $shared.github.branch
                $config["GITHUB_REPOSITORY_URL"] = Resolve-ConfigValue $shared.github.repositoryUrl
                $config["CSP_LEVEL"] = Resolve-ConfigValue $shared.security.cspLevel
                $config["PUBLIC_NETWORK_ACCESS"] = $shared.security.publicNetworkAccess
                
                Write-Verbose "Loaded shared configuration from environments.json"
            }
        }
        catch {
            Write-Warning "Failed to load environments.json: $($_.Exception.Message)"
        }
    }
    
    # 2. Load overrides from .env file
    $envFile = Join-Path $ConfigPath ".env"
    if (Test-Path $envFile) {
        Get-Content $envFile | ForEach-Object {
            if ($_ -match '^([^#][^=]+)=(.*)$') {
                $key = $matches[1].Trim()
                $value = $matches[2].Trim()
                $config[$key] = $value
                Write-Verbose "Override from .env: $key"
            }
        }
    }
    
    # 3. Override with environment variables if they exist
    $configKeys = @($config.Keys)
    $configKeys | ForEach-Object {
        $envValue = [Environment]::GetEnvironmentVariable($_)
        if ($envValue) {
            $config[$_] = $envValue
            Write-Verbose "Override from environment variable: $_"
        }
    }
    
    return $config
}

function Resolve-ConfigValue {
    param([string]$Value)
    
    if ([string]::IsNullOrEmpty($Value)) {
        return $Value
    }
    
    # Handle variable substitution like ${VAR_NAME} or ${VAR_NAME:-default}
    $pattern = '\$\{([^}:]+)(?::([^}]*))?\}'
    
    return [regex]::Replace($Value, $pattern, {
        param($match)
        $varName = $match.Groups[1].Value
        $defaultValue = $match.Groups[2].Value
        
        $envValue = [Environment]::GetEnvironmentVariable($varName)
        if ($envValue) {
            return $envValue
        } elseif ($defaultValue) {
            return $defaultValue
        } else {
            return ""
        }
    })
}

function Set-DeploymentEnvironment {
    param(
        [Parameter(Mandatory=$true)]
        [hashtable]$Config
    )
    
    Write-Host "Setting deployment environment variables..." -ForegroundColor Cyan
    
    foreach ($key in $Config.Keys) {
        [Environment]::SetEnvironmentVariable($key, $Config[$key], "Process")
        Write-Verbose "Set environment variable: $key"
    }
    
    Write-Host "✅ Environment variables configured" -ForegroundColor Green
}

function Get-AzureResourceNames {
    param(
        [Parameter(Mandatory=$true)]
        [hashtable]$Config
    )
    
    return @{
        ResourceGroup = $Config["AZURE_RESOURCE_GROUP_NAME"]
        StaticWebApp = $Config["AZURE_STATIC_WEB_APP_NAME"]
        Location = $Config["AZURE_LOCATION"]
        Environment = $Config["AZURE_ENV_NAME"]
        SubscriptionId = $Config["AZURE_SUBSCRIPTION_ID"]
        TenantId = $Config["AZURE_TENANT_ID"]
    }
}

function Test-ConfigurationValidation {
    param(
        [Parameter(Mandatory=$true)]
        [hashtable]$Config
    )
    
    $requiredVars = @(
        "AZURE_SUBSCRIPTION_ID",
        "AZURE_TENANT_ID",
        "AZURE_LOCATION",
        "AZURE_ENV_NAME",
        "AZURE_RESOURCE_GROUP_NAME",
        "AZURE_STATIC_WEB_APP_NAME"
    )
    
    $missingVars = @()
    foreach ($var in $requiredVars) {
        if ([string]::IsNullOrEmpty($Config[$var])) {
            $missingVars += $var
        }
    }
    
    if ($missingVars.Count -gt 0) {
        Write-Host "❌ Missing required configuration:" -ForegroundColor Red
        $missingVars | ForEach-Object { Write-Host "   • $_" -ForegroundColor Yellow }
        return $false
    }
    
    Write-Host "✅ All required configuration present" -ForegroundColor Green
    return $true
}

# Export functions for use in other scripts
Export-ModuleMember -Function Get-DeploymentConfig, Set-DeploymentEnvironment, Get-AzureResourceNames, Test-ConfigurationValidation
