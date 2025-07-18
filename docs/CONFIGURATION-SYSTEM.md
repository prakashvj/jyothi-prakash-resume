# ⚙️ Configuration System Guide

## 🎯 **What This Guide Does**
Provides **comprehensive understanding** of the centralized configuration system that powers multi-environment deployments. Essential for managing production, staging, and development environments with consistent settings and security best practices.

## 🔧 **How It Does It**
- **Centralized configuration management** avoiding hardcoded values throughout the project
- **Multi-environment support** with inheritance and override capabilities
- **Security-first approach** with git-ignored secrets and environment variable management
- **Validation system** ensuring configuration integrity before deployment
- **PowerShell integration** providing seamless access to settings across all scripts

## 📚 **Related Documentation**
- **[📖 Documentation Hub](README.md)** - Overview of all documentation
- **[🚀 Quick Start](QUICK-START.md)** - Fast setup using this configuration system
- **[📜 Scripts Reference](SCRIPTS-REFERENCE.md)** - How scripts use configuration functions
- **[🔧 Troubleshooting](TROUBLESHOOTING.md)** - Configuration problem resolution

---

This project uses a **centralized configuration system** that allows you to manage multiple environments (prod, staging, dev) with consistent settings and easy customization.

## 🏗️ Configuration Architecture

```
config/
├── environments.json      # Environment-specific settings
├── .env                  # Local overrides & secrets
├── .env.template         # Template for .env file
├── config.json          # Global configuration
└── settings.ini         # Legacy settings (deprecated)
```

## 📋 Core Components

### 1. Environment Configuration (`environments.json`)

**Purpose:** Defines environment-specific Azure resource settings

```json
{
  "environments": {
    "prod": {
      "azure": {
        "resourceGroup": "jyothi-resume-RG",
        "staticWebAppName": "jyothi-resume-WebApp",
        "location": "eastasia"
      },
      "deployment": {
        "validateDependencies": true,
        "skipBicepValidation": false
      }
    },
    "staging": {
      "azure": {
        "resourceGroup": "jyothi-resume-staging-RG",
        "staticWebAppName": "jyothi-resume-staging",
        "location": "eastus"
      }
    }
  }
}
```

**Key Features:**
- ✅ **Multi-Environment Support:** prod, staging, dev, custom
- ✅ **Inheritance:** Child environments inherit from parent
- ✅ **Validation Settings:** Control deployment behavior
- ✅ **Resource Naming:** Consistent Azure resource names

### 2. Local Environment File (`.env`)

**Purpose:** Store subscription details and local overrides

```ini
# Azure Authentication
AZURE_SUBSCRIPTION_ID=12345678-1234-1234-1234-123456789abc
AZURE_TENANT_ID=87654321-4321-4321-4321-cba987654321

# Optional Overrides
AZURE_LOCATION=eastasia
AZURE_ENV_NAME=prod
AZURE_RESOURCE_GROUP_NAME=custom-rg-name
```

**Security Features:**
- 🔒 **Git Ignored:** Never committed to repository
- 🔒 **Template Provided:** `.env.template` for easy setup
- 🔒 **Subscription Isolation:** Keep Azure credentials local

### 3. PowerShell Configuration Module (`ConfigModule.psm1`)

**Purpose:** Provides unified configuration access across all scripts

```powershell
# Load configuration for environment
$config = Get-DeploymentConfig -Environment "prod"

# Get Azure resource names
$resources = Get-AzureResourceNames -Environment "prod"

# Validate configuration
Test-ConfigurationValidation -Environment "prod"
```

## 🚀 Using the Configuration System

### Basic Usage

#### Load Configuration
```powershell
# Import the module
Import-Module .\scripts\ConfigModule.psm1 -Force

# Get configuration for production
$config = Get-DeploymentConfig -Environment "prod"

# Access Azure settings
$resourceGroup = $config.azure.resourceGroup
$webAppName = $config.azure.staticWebAppName
$location = $config.azure.location
```

#### Get Resource Names
```powershell
# Get all Azure resource names
$resources = Get-AzureResourceNames -Environment "prod"

Write-Host "Resource Group: $($resources.ResourceGroup)"
Write-Host "Web App: $($resources.StaticWebApp)"
Write-Host "Location: $($resources.Location)"
```

#### Validate Configuration
```powershell
# Validate environment configuration
if (Test-ConfigurationValidation -Environment "prod") {
    Write-Host "✅ Configuration is valid"
} else {
    Write-Host "❌ Configuration validation failed"
}
```

### Advanced Usage

#### Environment Inheritance
```json
{
  "environments": {
    "base": {
      "azure": {
        "location": "eastasia"
      },
      "deployment": {
        "validateDependencies": true
      }
    },
    "prod": {
      "inherits": "base",
      "azure": {
        "resourceGroup": "prod-rg",
        "staticWebAppName": "prod-webapp"
      }
    },
    "staging": {
      "inherits": "base",
      "azure": {
        "resourceGroup": "staging-rg",
        "staticWebAppName": "staging-webapp"
      }
    }
  }
}
```

#### Custom Environment Variables
```powershell
# Override settings via environment variables
$env:AZURE_RESOURCE_GROUP_NAME = "custom-rg"
$env:AZURE_STATIC_WEB_APP_NAME = "custom-webapp"

# Configuration system will use these overrides
$config = Get-DeploymentConfig -Environment "prod"
```

## 🔧 Configuration Precedence

The configuration system uses this precedence (highest to lowest):

1. **Environment Variables** (`.env` file or system)
2. **Environment-Specific Settings** (`environments.json`)
3. **Inherited Settings** (parent environment)
4. **Global Defaults** (`config.json`)

### Example Precedence Resolution
```json
// environments.json
{
  "environments": {
    "prod": {
      "azure": {
        "resourceGroup": "prod-rg",
        "location": "eastasia"
      }
    }
  }
}
```

```ini
# .env file
AZURE_RESOURCE_GROUP_NAME=override-rg
AZURE_LOCATION=westus
```

**Result:** Resource group = `override-rg`, Location = `westus`

## 📝 Configuration Schema

### Environment Configuration Schema
```json
{
  "environments": {
    "<environment-name>": {
      "inherits": "<parent-environment>",
      "azure": {
        "resourceGroup": "string",
        "staticWebAppName": "string", 
        "location": "string",
        "subscriptionId": "string",
        "tenantId": "string"
      },
      "deployment": {
        "validateDependencies": "boolean",
        "skipBicepValidation": "boolean",
        "timeoutMinutes": "number"
      },
      "validation": {
        "checkAzureCli": "boolean",
        "checkAzd": "boolean",
        "checkResourceGroup": "boolean"
      }
    }
  }
}
```

### Environment Variables Schema
```ini
# Required
AZURE_SUBSCRIPTION_ID=guid
AZURE_TENANT_ID=guid

# Optional Overrides
AZURE_LOCATION=azure-region
AZURE_ENV_NAME=environment-name
AZURE_RESOURCE_GROUP_NAME=resource-group-name
AZURE_STATIC_WEB_APP_NAME=static-web-app-name

# Deployment Options
SKIP_VALIDATION=true|false
FORCE_DEPLOYMENT=true|false
```

## 🛠️ Configuration Management

### Creating New Environments

#### 1. Add to environments.json
```json
{
  "environments": {
    "dev": {
      "azure": {
        "resourceGroup": "dev-rg",
        "staticWebAppName": "dev-webapp",
        "location": "eastus"
      },
      "deployment": {
        "validateDependencies": false
      }
    }
  }
}
```

#### 2. Deploy to new environment
```powershell
.\scripts\deploy-one-command.ps1 -Environment "dev"
```

### Updating Configurations

#### Modify Azure Resources
```json
{
  "environments": {
    "prod": {
      "azure": {
        "resourceGroup": "new-prod-rg",
        "staticWebAppName": "new-prod-webapp"
      }
    }
  }
}
```

#### Add Deployment Options
```json
{
  "environments": {
    "prod": {
      "deployment": {
        "validateDependencies": true,
        "skipBicepValidation": false,
        "timeoutMinutes": 30
      }
    }
  }
}
```

## 🔍 Configuration Validation

### Built-in Validation

The configuration system includes comprehensive validation:

```powershell
# Validate specific environment
.\scripts\validate-essentials.ps1 -Environment "prod"

# Validate all configurations
Test-ConfigurationValidation -Environment "prod"
```

**Validation Checks:**
- ✅ **Required Fields:** All mandatory configuration present
- ✅ **Azure Resources:** Resource names follow conventions
- ✅ **Dependencies:** Required tools installed
- ✅ **Authentication:** Azure CLI and AZD authenticated
- ✅ **Permissions:** Access to subscription and resource group

### Custom Validation Rules
```json
{
  "environments": {
    "prod": {
      "validation": {
        "checkAzureCli": true,
        "checkAzd": true,
        "checkResourceGroup": true,
        "enforceNamingConvention": true
      }
    }
  }
}
```

## 🚨 Troubleshooting Configuration

### Common Issues

#### Issue: "Configuration not found"
```powershell
# Check if environments.json exists
Test-Path "config\environments.json"

# Validate JSON syntax
Get-Content "config\environments.json" | ConvertFrom-Json
```

#### Issue: "Environment variables not loaded"
```powershell
# Check .env file
Test-Path "config\.env"

# Load manually
Get-Content "config\.env" | ForEach-Object {
    if ($_ -match "^([^=]+)=(.*)$") {
        [Environment]::SetEnvironmentVariable($matches[1], $matches[2])
    }
}
```

#### Issue: "Azure authentication failed"
```powershell
# Verify Azure authentication
az account show
azd auth login

# Check subscription access
az account list --output table
```

## 📚 Migration Guide

### From Legacy Configuration

If migrating from hardcoded configurations:

#### 1. Extract hardcoded values
```powershell
# Old way (hardcoded)
$resourceGroup = "hardcoded-rg"
$webAppName = "hardcoded-webapp"

# New way (centralized)
$config = Get-DeploymentConfig -Environment "prod"
$resourceGroup = $config.azure.resourceGroup
$webAppName = $config.azure.staticWebAppName
```

#### 2. Update all scripts
```powershell
# Replace hardcoded values with configuration calls
Import-Module .\scripts\ConfigModule.psm1 -Force
$config = Get-DeploymentConfig -Environment $Environment
```

#### 3. Create environment files
- Move settings to `environments.json`
- Create `.env` for local overrides
- Remove hardcoded values

## 🎯 Best Practices

### 1. Environment Management
- ✅ Use descriptive environment names (`prod`, `staging`, `dev`)
- ✅ Leverage inheritance for common settings
- ✅ Keep sensitive data in `.env` (git-ignored)
- ✅ Use consistent naming conventions

### 2. Security
- 🔒 Never commit `.env` files
- 🔒 Use Azure CLI authentication
- 🔒 Rotate deployment tokens regularly
- 🔒 Limit subscription permissions

### 3. Deployment
- 🚀 Validate configuration before deployment
- 🚀 Use environment-specific resource groups
- 🚀 Test in staging before production
- 🚀 Monitor deployment logs

---

**Next Steps:**
- 📖 [Quick Start Guide](QUICK-START.md)
- 🚀 [Deployment Reference](DEPLOYMENT-REFERENCE.md)
- 📝 [Scripts Reference](SCRIPTS-REFERENCE.md)
