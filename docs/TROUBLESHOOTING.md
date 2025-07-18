# 🔧 Troubleshooting Guide

## 🎯 **What This Guide Does**
Provides **comprehensive problem resolution** for all common issues with Azure Static Web Apps deployment, configuration management, and script execution. Essential for quickly diagnosing and fixing problems during setup and deployment.

## 🔧 **How It Does It**
- **Quick issue resolution table** for immediate problem identification
- **Step-by-step diagnostic procedures** with validation commands
- **Common error patterns** with specific solutions and explanations
- **Preventive maintenance tips** to avoid problems before they occur
- **Emergency recovery procedures** for critical deployment failures

## 📚 **Related Documentation**
- **[📖 Documentation Hub](README.md)** - Overview of all documentation
- **[🚀 Quick Start](QUICK-START.md)** - Basic setup to avoid common issues
- **[⚙️ Configuration System](CONFIGURATION-SYSTEM.md)** - Configuration-specific troubleshooting
- **[📜 Scripts Reference](SCRIPTS-REFERENCE.md)** - Script-specific error resolution

---

Comprehensive troubleshooting guide for common issues with the Azure Static Web Apps deployment system.

## 🚨 Quick Issue Resolution

| Issue Type | Quick Fix | Script to Run |
|------------|-----------|---------------|
| Authentication | `az login && azd auth login` | `validate-essentials.ps1 -Quick` |
| Configuration | Check `.env` file | `config-loader.ps1 -ValidateOnly` |
| Deployment | Retry with force | `quick-deploy.ps1 -Force` |
| Validation | Skip problematic checks | `deploy-one-command.ps1 -SkipValidation` |
| Network | Check connectivity | `validate-deployment.ps1 -SkipSSL` |

## 🔐 Authentication Issues

### Issue: "Not authenticated to Azure"

**Symptoms:**
```
❌ Error: Please run 'az login' to authenticate
❌ Azure CLI authentication failed
❌ No valid Azure subscription found
```

**Solutions:**

#### 1. Basic Authentication
```powershell
# Login to Azure CLI
az login

# Verify authentication
az account show

# Login to Azure Developer CLI
azd auth login

# Verify AZD authentication
azd auth status
```

#### 2. Service Principal Authentication
```powershell
# For CI/CD scenarios
az login --service-principal \
  --username $env:AZURE_CLIENT_ID \
  --password $env:AZURE_CLIENT_SECRET \
  --tenant $env:AZURE_TENANT_ID
```

#### 3. Clear Authentication Cache
```powershell
# Clear Azure CLI cache
az account clear

# Clear AZD cache
azd auth logout

# Re-authenticate
az login
azd auth login
```

**Validation:**
```powershell
# Test authentication
.\scripts\validate-essentials.ps1 -Environment "prod" -Quick
```

---

### Issue: "Subscription not found"

**Symptoms:**
```
❌ Error: Subscription 'xxx' was not found
❌ The provided subscription ID is invalid
❌ No subscription found matching the criteria
```

**Solutions:**

#### 1. List Available Subscriptions
```powershell
# List all subscriptions
az account list --output table

# Set correct subscription
az account set --subscription "your-subscription-id"
```

#### 2. Update Configuration
```ini
# Update config/.env file
AZURE_SUBSCRIPTION_ID=correct-subscription-id-here
AZURE_TENANT_ID=correct-tenant-id-here
```

#### 3. Verify Subscription Access
```powershell
# Check subscription details
az account show --subscription "your-subscription-id"

# List resource groups in subscription
az group list --subscription "your-subscription-id"
```

---

## ⚙️ Configuration Issues

### Issue: "Configuration file not found"

**Symptoms:**
```
❌ Error: Cannot find configuration file 'config/environments.json'
❌ Error: Environment 'prod' not found in configuration
❌ Configuration validation failed
```

**Solutions:**

#### 1. Check File Existence
```powershell
# Verify files exist
Test-Path "config/environments.json"
Test-Path "config/.env"

# List config directory
Get-ChildItem "config/" -Force
```

#### 2. Create Missing Files
```powershell
# Create .env from template
Copy-Item "config/.env.template" "config/.env"

# Edit .env file with your values
notepad "config/.env"
```

#### 3. Validate JSON Syntax
```powershell
# Test JSON syntax
try {
    Get-Content "config/environments.json" | ConvertFrom-Json
    Write-Host "✅ JSON syntax is valid"
} catch {
    Write-Host "❌ JSON syntax error: $($_.Exception.Message)"
}
```

**Fix Configuration:**
```powershell
# Test configuration loading
.\scripts\config-loader.ps1 -Environment "prod" -ValidateOnly
```

---

### Issue: "Environment not found"

**Symptoms:**
```
❌ Error: Environment 'staging' not found in environments.json
❌ Configuration for environment 'dev' is missing
```

**Solutions:**

#### 1. Check Available Environments
```powershell
# List configured environments
$config = Get-Content "config/environments.json" | ConvertFrom-Json
$config.environments | Get-Member -MemberType NoteProperty | Select-Object Name
```

#### 2. Add Missing Environment
```json
{
  "environments": {
    "prod": { /* existing config */ },
    "staging": {
      "azure": {
        "resourceGroup": "jyothi-resume-staging-RG",
        "staticWebAppName": "jyothi-resume-staging",
        "location": "eastasia"
      }
    }
  }
}
```

#### 3. Use Correct Environment Name
```powershell
# Use existing environment
.\scripts\deploy-one-command.ps1 -Environment "prod"  # Not "production"
```

---

## 🌐 Deployment Issues

### Issue: "Static Web App deployment failed"

**Symptoms:**
```
❌ Error: Deployment to Static Web App failed
❌ HTTP 401: Unauthorized deployment
❌ Build process failed during deployment
```

**Solutions:**

#### 1. Check Deployment Token
```powershell
# Get new deployment token
az staticwebapp secrets list \
  --name "jyothi-resume-WebApp" \
  --resource-group "jyothi-resume-RG"
```

#### 2. Verify Resource Exists
```powershell
# Check if Static Web App exists
az staticwebapp show \
  --name "jyothi-resume-WebApp" \
  --resource-group "jyothi-resume-RG"

# List all Static Web Apps
az staticwebapp list --output table
```

#### 3. Check Source Files
```powershell
# Verify source directory exists
Test-Path "src/"

# Check required files
Test-Path "src/index.html"
Test-Path "src/css/style.css"
```

#### 4. Manual Deployment
```powershell
# Force deployment with verbose output
.\scripts\quick-deploy.ps1 -Environment "prod" -Force -Verbose
```

**Deploy with AZD:**
```powershell
# Alternative deployment method
azd deploy --environment prod
```

---

### Issue: "Resource group does not exist"

**Symptoms:**
```
❌ Error: Resource group 'jyothi-resume-RG' was not found
❌ The specified resource group does not exist
```

**Solutions:**

#### 1. Create Resource Group
```powershell
# Create resource group
az group create \
  --name "jyothi-resume-RG" \
  --location "eastasia"
```

#### 2. Check Resource Group Name
```powershell
# List existing resource groups
az group list --output table

# Update configuration if needed
# Edit config/environments.json or config/.env
```

#### 3. Run Preparation Script
```powershell
# Create missing resources
.\scripts\prepare-deployment.ps1 -Environment "prod" -InstallMissing
```

---

## 🔗 Network & Connectivity Issues

### Issue: "Website not accessible"

**Symptoms:**
```
❌ HTTP 404: Not Found
❌ DNS_PROBE_FINISHED_NXDOMAIN
❌ Site cannot be reached
```

**Solutions:**

#### 1. Check Deployment Status
```powershell
# Verify deployment completed
az staticwebapp show \
  --name "jyothi-resume-WebApp" \
  --resource-group "jyothi-resume-RG" \
  --query "defaultHostname"
```

#### 2. Test Direct URL
```powershell
# Test the Azure-provided URL
$url = "https://jyothi-resume-WebApp.azurestaticapps.net"
try {
    $response = Invoke-WebRequest -Uri $url -Method Head
    Write-Host "✅ Website accessible: $($response.StatusCode)"
} catch {
    Write-Host "❌ Website not accessible: $($_.Exception.Message)"
}
```

#### 3. Check DNS Resolution
```powershell
# Test DNS resolution
nslookup jyothi-resume-WebApp.azurestaticapps.net

# Test with different DNS server
nslookup jyothi-resume-WebApp.azurestaticapps.net 8.8.8.8
```

#### 4. Validate Content
```powershell
# Run comprehensive validation
.\scripts\validate-deployment.ps1 -Environment "prod" -IncludePerformance
```

---

### Issue: "SSL certificate invalid"

**Symptoms:**
```
❌ SSL certificate verification failed
❌ NET::ERR_CERT_AUTHORITY_INVALID
❌ Your connection is not private
```

**Solutions:**

#### 1. Check Certificate Status
```powershell
# Check SSL certificate
openssl s_client -connect jyothi-resume-WebApp.azurestaticapps.net:443 -servername jyothi-resume-WebApp.azurestaticapps.net

# Or use PowerShell
$cert = [System.Net.ServicePointManager]::ServerCertificateValidationCallback = {$true}
```

#### 2. Wait for Certificate Provisioning
```powershell
# Azure may take time to provision certificates
# Wait 5-10 minutes after deployment

# Check again
.\scripts\validate-deployment.ps1 -Environment "prod"
```

#### 3. Skip SSL Validation (Temporary)
```powershell
# For testing only
.\scripts\validate-deployment.ps1 -Environment "prod" -SkipSSL
```

---

## 📦 Build & Content Issues

### Issue: "Build process failed"

**Symptoms:**
```
❌ Error: Build command failed
❌ npm install failed
❌ Missing build dependencies
```

**Solutions:**

#### 1. Check Build Requirements
```powershell
# Verify Node.js if needed
node --version
npm --version

# Install dependencies
npm install
```

#### 2. Manual Build
```powershell
# Test build locally
cd src/
# Run any build commands manually

# Deploy pre-built content
.\scripts\quick-deploy.ps1 -Environment "prod" -SkipBuild
```

#### 3. Check Source Files
```powershell
# Verify all required files exist
Test-Path "src/index.html"
Test-Path "src/css/*.css"
Test-Path "src/js/*.js"

# Check file permissions
Get-ChildItem "src/" -Recurse | Select-Object Name, Mode
```

---

### Issue: "Content not updating"

**Symptoms:**
```
❌ Website shows old content after deployment
❌ CSS/JS changes not reflected
❌ Cache issues
```

**Solutions:**

#### 1. Clear Browser Cache
```
Ctrl + F5 (Hard refresh)
Ctrl + Shift + R (Chrome/Firefox)
Open Incognito/Private window
```

#### 2. Force Deployment
```powershell
# Force content update
.\scripts\quick-deploy.ps1 -Environment "prod" -Force
```

#### 3. Check Deployment Status
```powershell
# Verify deployment completed
az staticwebapp deployment list \
  --name "jyothi-resume-WebApp" \
  --resource-group "jyothi-resume-RG"
```

#### 4. Add Cache-Busting
```html
<!-- Add version parameter to CSS/JS files -->
<link rel="stylesheet" href="css/style.css?v=20241201">
<script src="js/main.js?v=20241201"></script>
```

---

## 🔧 PowerShell Script Issues

### Issue: "Execution Policy Restricted"

**Symptoms:**
```
❌ cannot be loaded because running scripts is disabled on this system
❌ Execution Policy: Restricted
```

**Solutions:**

#### 1. Check Current Policy
```powershell
Get-ExecutionPolicy -Scope CurrentUser
```

#### 2. Set Execution Policy
```powershell
# For current user only (recommended)
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser

# Or bypass for single command
PowerShell -ExecutionPolicy Bypass -File "scripts\deploy-one-command.ps1"
```

#### 3. Unblock Scripts
```powershell
# Unblock downloaded scripts
Get-ChildItem "scripts\*.ps1" | Unblock-File
```

---

### Issue: "Module not found"

**Symptoms:**
```
❌ Module 'ConfigModule' could not be loaded
❌ The specified module was not loaded
```

**Solutions:**

#### 1. Import Module Manually
```powershell
# Import the configuration module
Import-Module ".\scripts\ConfigModule.psm1" -Force

# Verify module loaded
Get-Module ConfigModule
```

#### 2. Check Module Path
```powershell
# Verify module file exists
Test-Path "scripts\ConfigModule.psm1"

# Check module syntax
Import-Module ".\scripts\ConfigModule.psm1" -Force -Verbose
```

#### 3. Reinstall Module
```powershell
# Remove and re-import
Remove-Module ConfigModule -ErrorAction SilentlyContinue
Import-Module ".\scripts\ConfigModule.psm1" -Force
```

---

## 🔍 Diagnostic Commands

### System Diagnostics

```powershell
# Check PowerShell version
$PSVersionTable

# Check Azure CLI version
az --version

# Check AZD version
azd version

# Check authentication status
az account show
azd auth status

# Test network connectivity
Test-NetConnection -ComputerName "management.azure.com" -Port 443
```

### Configuration Diagnostics

```powershell
# Test configuration loading
.\scripts\config-loader.ps1 -Environment "prod" -ShowAll

# Validate all environments
$environments = @("prod", "staging", "dev")
foreach ($env in $environments) {
    Write-Host "Testing environment: $env"
    try {
        .\scripts\config-loader.ps1 -Environment $env -ValidateOnly
        Write-Host "✅ $env: Valid"
    } catch {
        Write-Host "❌ $env: $($_.Exception.Message)"
    }
}
```

### Deployment Diagnostics

```powershell
# Check Azure resources
az group list --output table
az staticwebapp list --output table

# Test deployment prerequisites
.\scripts\prepare-deployment.ps1 -Environment "prod"

# Run comprehensive validation
.\scripts\validate-essentials.ps1 -Environment "prod" -Detailed
```

---

## 📊 Performance Issues

### Issue: "Slow deployment"

**Symptoms:**
```
⏱️ Deployment taking > 10 minutes
⏱️ Upload speed very slow
⏱️ Timeout errors during deployment
```

**Solutions:**

#### 1. Use Quick Deploy
```powershell
# For content-only changes
.\scripts\quick-deploy.ps1 -Environment "prod"
```

#### 2. Check Network Speed
```powershell
# Test upload speed to Azure
# Use Azure Storage Explorer or similar tool
```

#### 3. Optimize Content
```powershell
# Minify CSS/JS files
# Compress images
# Remove unnecessary files from src/
```

---

### Issue: "Website loads slowly"

**Solutions:**

#### 1. Enable CDN
```powershell
# Configure Azure CDN (if not already done)
az cdn profile create \
  --name "jyothi-resume-cdn" \
  --resource-group "jyothi-resume-RG" \
  --sku "Standard_Microsoft"
```

#### 2. Optimize Assets
```html
<!-- Optimize images -->
<img src="image.webp" alt="Description" loading="lazy">

<!-- Minify CSS/JS -->
<link rel="stylesheet" href="css/style.min.css">
<script src="js/main.min.js" async></script>
```

#### 3. Check Performance
```powershell
# Run performance validation
.\scripts\validate-deployment.ps1 -Environment "prod" -IncludePerformance
```

---

## 🆘 Emergency Procedures

### Complete Reset

If everything fails, perform a complete reset:

```powershell
# 1. Clear authentication
az logout
azd auth logout

# 2. Re-authenticate
az login
azd auth login

# 3. Validate configuration
.\scripts\config-loader.ps1 -Environment "prod" -ValidateOnly

# 4. Prepare deployment
.\scripts\prepare-deployment.ps1 -Environment "prod" -InstallMissing

# 5. Deploy with force
.\scripts\deploy-one-command.ps1 -Environment "prod" -Force
```

### Rollback Deployment

```powershell
# List recent deployments
az staticwebapp deployment list \
  --name "jyothi-resume-WebApp" \
  --resource-group "jyothi-resume-RG"

# Rollback to previous version (if available)
# Note: Azure Static Web Apps doesn't support direct rollback
# You'll need to redeploy previous version from source control
```

### Contact Support

If issues persist:

1. **GitHub Issues:** Create issue with logs and error messages
2. **Azure Support:** For Azure-specific issues
3. **Community:** Stack Overflow with tags `azure-static-web-apps`, `powershell`

**Include in support request:**
- Error messages (full text)
- Configuration files (anonymized)
- Script output logs
- Environment details (OS, PowerShell version, etc.)

---

## 🔄 Prevention Tips

### 1. Regular Maintenance
```powershell
# Weekly validation
.\scripts\validate-essentials.ps1 -Environment "prod" -Detailed

# Monthly authentication refresh
az login
azd auth login
```

### 2. Configuration Backup
```powershell
# Backup configuration
Copy-Item "config/" "config-backup-$(Get-Date -Format 'yyyyMMdd')/" -Recurse
```

### 3. Monitor Deployments
```powershell
# Log all deployments
.\scripts\deploy-one-command.ps1 -Environment "prod" | 
  Tee-Object -FilePath "logs/deployment-$(Get-Date -Format 'yyyyMMdd-HHmmss').log"
```

---

**Need More Help?**
- 📖 [Quick Start Guide](QUICK-START.md)
- ⚙️ [Configuration System](CONFIGURATION-SYSTEM.md)
- 📜 [Scripts Reference](SCRIPTS-REFERENCE.md)
- 🚀 [Deployment Reference](DEPLOYMENT-REFERENCE.md)
