# 📜 Scripts Reference Guide

## 🎯 **What This Guide Does**
Provides **complete reference documentation** for all PowerShell deployment and management scripts. Essential for understanding script parameters, usage patterns, and advanced automation scenarios with the centralized configuration system.

## 🔧 **How It Does It**
- **Comprehensive parameter documentation** for all scripts with examples
- **Usage patterns and workflows** for different deployment scenarios
- **Performance optimization guidance** for efficient deployments
- **Integration examples** showing how scripts work together
- **Error handling reference** with exit codes and troubleshooting

## 📚 **Related Documentation**
- **[📖 Documentation Hub](README.md)** - Overview of all documentation
- **[🚀 Quick Start](QUICK-START.md)** - Basic script usage for beginners
- **[⚙️ Configuration System](CONFIGURATION-SYSTEM.md)** - How scripts access configuration
- **[🚀 Deployment Reference](DEPLOYMENT-REFERENCE.md)** - Advanced deployment strategies

---

Complete reference for all PowerShell deployment and management scripts in the project.

## 📁 Script Overview

| Script | Purpose | Usage | Environment |
|--------|---------|-------|-------------|
| `deploy-one-command.ps1` | 🚀 Full deployment (infrastructure + content) | One-time setup | Any |
| `quick-deploy.ps1` | ⚡ Content-only deployment | Regular updates | Any |
| `validate-essentials.ps1` | ✅ Essential validation checks | Pre-deployment | Any |
| `validate-deployment.ps1` | 🔍 Comprehensive validation | Post-deployment | Any |
| `config-loader.ps1` | ⚙️ Configuration management | Testing/debugging | Any |
| `prepare-deployment.ps1` | 🛠️ Deployment preparation | Setup validation | Any |

## 🚀 Main Deployment Scripts

### deploy-one-command.ps1

**Purpose:** Complete end-to-end deployment including infrastructure provisioning and content deployment.

**Usage:**
```powershell
.\scripts\deploy-one-command.ps1 -Environment "prod"
.\scripts\deploy-one-command.ps1 -Environment "staging" -Force
.\scripts\deploy-one-command.ps1 -Environment "dev" -SkipValidation
```

**Parameters:**
- `-Environment` (Required): Target environment (prod, staging, dev, etc.)
- `-Force` (Optional): Force deployment even if validation warnings exist
- `-SkipValidation` (Optional): Skip pre-deployment validation checks

**What it does:**
1. ✅ Validates configuration and prerequisites
2. 🔧 Creates/updates Azure infrastructure (Resource Group, Static Web App)
3. 📦 Builds and deploys website content
4. 🔍 Performs post-deployment validation
5. 🌐 Returns live website URL

**Example Output:**
```
🚀 Starting deployment to environment: prod
✅ Configuration validation passed
✅ Azure authentication verified
🔧 Creating Azure resources...
📦 Deploying website content...
🎉 DEPLOYMENT SUCCESSFUL!
🌐 Live URL: https://jyothi-resume-WebApp.azurestaticapps.net
```

---

### quick-deploy.ps1

**Purpose:** Fast content-only deployment for website updates (skips infrastructure changes).

**Usage:**
```powershell
.\scripts\quick-deploy.ps1 -Environment "prod"
.\scripts\quick-deploy.ps1 -Environment "staging" -Source "src"
.\scripts\quick-deploy.ps1 -Environment "dev" -SkipBuild
```

**Parameters:**
- `-Environment` (Required): Target environment
- `-Source` (Optional): Source directory for content (default: "src")
- `-SkipBuild` (Optional): Skip build process and deploy existing files
- `-Force` (Optional): Force deployment without confirmation

**What it does:**
1. ⚡ Loads environment configuration
2. 🔧 Validates Azure resources exist
3. 📦 Builds content (if not skipped)
4. 🚀 Deploys to existing Static Web App
5. ✅ Verifies deployment success

**Use Cases:**
- Regular content updates
- Bug fixes
- CSS/JS changes
- Resume content updates

---

## ✅ Validation Scripts

### validate-essentials.ps1

**Purpose:** Essential pre-deployment validation checks.

**Usage:**
```powershell
.\scripts\validate-essentials.ps1 -Environment "prod"
.\scripts\validate-essentials.ps1 -Environment "staging" -Quick
.\scripts\validate-essentials.ps1 -Environment "dev" -Detailed
```

**Parameters:**
- `-Environment` (Required): Target environment
- `-Quick` (Optional): Run only critical checks
- `-Detailed` (Optional): Run comprehensive validation

**Validation Checks:**
- 🔐 **Azure Authentication:** CLI and AZD login status
- ⚙️ **Configuration:** Environment settings validity
- 🛠️ **Prerequisites:** Required tools installation
- 📁 **File Structure:** Project files and directories
- 🌐 **Network:** Azure service connectivity

**Quick Mode Checks:**
- Azure CLI authentication
- Basic configuration loading
- Critical file existence

**Detailed Mode Checks:**
- All quick mode checks plus:
- Azure subscription permissions
- Resource group access
- Static Web App configuration
- Network connectivity tests

---

### validate-deployment.ps1

**Purpose:** Comprehensive post-deployment validation and health checks.

**Usage:**
```powershell
.\scripts\validate-deployment.ps1 -Environment "prod"
.\scripts\validate-deployment.ps1 -Environment "staging" -IncludePerformance
.\scripts\validate-deployment.ps1 -Environment "dev" -SkipSSL
```

**Parameters:**
- `-Environment` (Required): Target environment to validate
- `-IncludePerformance` (Optional): Include performance and load testing
- `-SkipSSL` (Optional): Skip SSL certificate validation
- `-Timeout` (Optional): HTTP request timeout in seconds (default: 30)

**Validation Areas:**
- 🌐 **Website Accessibility:** HTTP status and response validation
- 🔒 **SSL/TLS:** Certificate validity and security headers
- 📱 **Responsive Design:** Mobile and desktop layout checks
- ⚡ **Performance:** Load times and resource optimization
- 🎯 **Content Integrity:** Expected content presence
- 🔍 **SEO Elements:** Meta tags and structured data

---

## ⚙️ Configuration & Utility Scripts

### config-loader.ps1

**Purpose:** Configuration management and testing utility.

**Usage:**
```powershell
.\scripts\config-loader.ps1 -Environment "prod"
.\scripts\config-loader.ps1 -Environment "staging" -ValidateOnly
.\scripts\config-loader.ps1 -Environment "dev" -ShowAll
```

**Parameters:**
- `-Environment` (Required): Target environment
- `-ValidateOnly` (Optional): Only validate, don't load configuration
- `-ShowAll` (Optional): Display complete configuration details
- `-TestConnection` (Optional): Test Azure connectivity

**Functions:**
- 📋 **Configuration Loading:** Load and display environment settings
- ✅ **Validation:** Verify configuration integrity
- 🔧 **Testing:** Test Azure resource connectivity
- 📊 **Reporting:** Generate configuration reports

**Example Output:**
```
⚙️ Configuration for environment: prod
📋 Resource Group: jyothi-resume-RG
🌐 Static Web App: jyothi-resume-WebApp
📍 Location: eastasia
✅ Configuration validation: PASSED
🔗 Azure connectivity: VERIFIED
```

---

### prepare-deployment.ps1

**Purpose:** Deployment preparation and dependency validation.

**Usage:**
```powershell
.\scripts\prepare-deployment.ps1 -Environment "prod"
.\scripts\prepare-deployment.ps1 -Environment "staging" -InstallMissing
.\scripts\prepare-deployment.ps1 -Environment "dev" -SkipDependencies
```

**Parameters:**
- `-Environment` (Required): Target environment
- `-InstallMissing` (Optional): Automatically install missing dependencies
- `-SkipDependencies` (Optional): Skip dependency checks
- `-Force` (Optional): Force preparation even if issues found

**Preparation Steps:**
1. 🔍 **Dependency Verification:** Check required tools and modules
2. 🔐 **Authentication Setup:** Verify Azure CLI and AZD authentication
3. ⚙️ **Configuration Validation:** Ensure environment settings are correct
4. 📁 **File Preparation:** Verify source files and build requirements
5. 🌐 **Network Checks:** Test Azure service connectivity
6. 🛠️ **Resource Validation:** Verify Azure resources exist or can be created

**Dependencies Checked:**
- Azure CLI (`az`)
- Azure Developer CLI (`azd`)
- PowerShell modules
- Git (for source control)
- Node.js (if needed for builds)

---

## 🔧 ConfigModule.psm1

**Purpose:** PowerShell module providing centralized configuration functions.

**Key Functions:**

#### Get-DeploymentConfig
```powershell
$config = Get-DeploymentConfig -Environment "prod"
```
- Loads complete environment configuration
- Merges environment-specific and global settings
- Applies environment variable overrides

#### Get-AzureResourceNames
```powershell
$resources = Get-AzureResourceNames -Environment "prod"
```
- Returns Azure resource names for environment
- Provides consistent naming across scripts
- Supports custom naming patterns

#### Test-ConfigurationValidation
```powershell
$isValid = Test-ConfigurationValidation -Environment "prod"
```
- Validates configuration completeness
- Checks required fields and formats
- Returns boolean validation result

#### Import-EnvironmentVariables
```powershell
Import-EnvironmentVariables -EnvironmentFile "config\.env"
```
- Loads environment variables from .env file
- Supports local configuration overrides
- Handles secure credential management

---

## 🎯 Common Usage Patterns

### 1. First-Time Deployment
```powershell
# Step 1: Prepare environment
.\scripts\prepare-deployment.ps1 -Environment "prod" -InstallMissing

# Step 2: Validate essentials
.\scripts\validate-essentials.ps1 -Environment "prod" -Detailed

# Step 3: Deploy everything
.\scripts\deploy-one-command.ps1 -Environment "prod"

# Step 4: Validate deployment
.\scripts\validate-deployment.ps1 -Environment "prod" -IncludePerformance
```

### 2. Regular Content Updates
```powershell
# Quick validation
.\scripts\validate-essentials.ps1 -Environment "prod" -Quick

# Deploy content only
.\scripts\quick-deploy.ps1 -Environment "prod"

# Verify deployment
.\scripts\validate-deployment.ps1 -Environment "prod"
```

### 3. Debugging Configuration
```powershell
# Test configuration loading
.\scripts\config-loader.ps1 -Environment "prod" -ShowAll

# Validate configuration only
.\scripts\config-loader.ps1 -Environment "prod" -ValidateOnly

# Test Azure connectivity
.\scripts\config-loader.ps1 -Environment "prod" -TestConnection
```

### 4. Multi-Environment Setup
```powershell
# Deploy to staging first
.\scripts\deploy-one-command.ps1 -Environment "staging"
.\scripts\validate-deployment.ps1 -Environment "staging"

# Then deploy to production
.\scripts\deploy-one-command.ps1 -Environment "prod"
.\scripts\validate-deployment.ps1 -Environment "prod"
```

---

## 🚨 Error Handling

### Common Exit Codes
- `0`: Success
- `1`: General error or validation failure
- `2`: Configuration error
- `3`: Azure authentication error
- `4`: Resource not found error
- `5`: Network/connectivity error

### Script Error Patterns
```powershell
# All scripts follow this pattern:
try {
    # Script logic
    Write-Host "✅ Success message" -ForegroundColor Green
    exit 0
} catch {
    Write-Host "❌ Error: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}
```

### Debugging Tips
```powershell
# Enable verbose output
$VerbosePreference = "Continue"
.\scripts\deploy-one-command.ps1 -Environment "prod" -Verbose

# Enable debug output
$DebugPreference = "Continue"
.\scripts\validate-essentials.ps1 -Environment "prod" -Debug

# Capture script output
.\scripts\quick-deploy.ps1 -Environment "prod" | Tee-Object -FilePath "deployment.log"
```

---

## 📊 Script Performance

### Execution Times (Typical)
- `validate-essentials.ps1` (Quick): 10-15 seconds
- `validate-essentials.ps1` (Detailed): 30-45 seconds
- `quick-deploy.ps1`: 2-5 minutes
- `deploy-one-command.ps1`: 5-10 minutes
- `validate-deployment.ps1`: 30-60 seconds
- `config-loader.ps1`: 5-10 seconds
- `prepare-deployment.ps1`: 15-30 seconds

### Optimization Tips
- Use `-Quick` mode for validation during development
- Use `quick-deploy.ps1` for content-only changes
- Run `prepare-deployment.ps1` once per session
- Cache Azure authentication tokens

---

**Next Steps:**
- 📖 [Quick Start Guide](QUICK-START.md)
- ⚙️ [Configuration System](CONFIGURATION-SYSTEM.md)
- 🚀 [Deployment Reference](DEPLOYMENT-REFERENCE.md)
- 🔧 [Troubleshooting Guide](TROUBLESHOOTING.md)
