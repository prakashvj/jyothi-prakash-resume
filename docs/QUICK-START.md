# 🚀 Quick Start Guide

## 🎯 **What This Guide Does**
Gets your resume website **deployed to Azure in 5 minutes** with minimal configuration. Perfect for first-time users who want to see immediate results and understand the basic deployment workflow.

## 🔧 **How It Does It**
- **Streamlined setup process** with only essential configuration steps
- **One-command deployment** that handles infrastructure and content automatically
- **Built-in validation** to catch issues before deployment starts
- **Live URL generation** so you can see your website immediately
- **Quick troubleshooting** for common first-time setup issues

## 📚 **Related Documentation**
- **[📖 Documentation Hub](README.md)** - Overview of all documentation
- **[⚙️ Configuration System](CONFIGURATION-SYSTEM.md)** - Deep dive into configuration management
- **[🔧 Troubleshooting](TROUBLESHOOTING.md)** - Solutions for common issues
- **[📜 Scripts Reference](SCRIPTS-REFERENCE.md)** - Complete script documentation

---

Get your resume website deployed to Azure in 5 minutes!

## Prerequisites

- **Azure Account** with active subscription
- **PowerShell 5.1+** (Windows) or **PowerShell Core 7+** (cross-platform)
- **Azure CLI** installed and configured
- **Git** for repository management

## Step 1: Initial Setup

### 1.1 Clone Repository
```bash
git clone https://github.com/prakashvj/jyothi-prakash-resume.git
cd jyothi-prakash-resume
```

### 1.2 Azure Authentication
```powershell
# Login to Azure
az login

# Verify you're logged in
az account show
```

### 1.3 Install Azure Developer CLI (if needed)
```powershell
# Windows (PowerShell)
winget install microsoft.azd

# macOS
brew tap azure/azd && brew install azd

# Linux
curl -fsSL https://aka.ms/install-azd.sh | bash
```

## Step 2: Configure Your Environment

### 2.1 Copy Environment Template
```powershell
# Copy template to create your environment file
cp config\.env.template config\.env
```

### 2.2 Update Configuration
Edit `config\.env` with your Azure details:

```ini
# Required: Your Azure subscription information
AZURE_SUBSCRIPTION_ID=your-subscription-id-here
AZURE_TENANT_ID=your-tenant-id-here

# Optional: Customize resource names (defaults provided)
AZURE_LOCATION=eastasia
AZURE_ENV_NAME=prod
AZURE_RESOURCE_GROUP_NAME=jyothi-resume-RG
AZURE_STATIC_WEB_APP_NAME=jyothi-resume-WebApp
```

### 2.3 Get Your Azure IDs
```powershell
# Get subscription ID and tenant ID
az account show --query "{subscriptionId:id, tenantId:tenantId}" --output table
```

## Step 3: Deploy Your Website

### 3.1 One-Command Deployment
```powershell
# Deploy everything (infrastructure + website)
.\scripts\deploy-one-command.ps1 -Environment "prod"
```

This command will:
- ✅ Validate all prerequisites
- ✅ Create Azure resources (if needed)
- ✅ Deploy your website
- ✅ Provide the live URL

### 3.2 Quick Content Updates (for future changes)
```powershell
# Deploy only content changes (faster)
.\scripts\quick-deploy.ps1 -Environment "prod"
```

## Step 4: Verify Deployment

### 4.1 Check Your Website
The deployment script will display your live URL:
```
🎉 DEPLOYMENT SUCCESSFUL!
🌐 Live URL: https://your-app-name.azurestaticapps.net
```

### 4.2 Validate Everything Works
```powershell
# Run comprehensive validation
.\scripts\validate-deployment.ps1 -Environment "prod"
```

## 🎯 Common Customizations

### Change Resource Names
Edit `config\environments.json`:
```json
{
  "environments": {
    "prod": {
      "azure": {
        "resourceGroup": "my-custom-rg",
        "staticWebAppName": "my-custom-webapp"
      }
    }
  }
}
```

### Add New Environment
```json
{
  "environments": {
    "staging": {
      "azure": {
        "resourceGroup": "my-app-staging-rg",
        "staticWebAppName": "my-app-staging"
      }
    }
  }
}
```

Deploy to staging:
```powershell
.\scripts\deploy-one-command.ps1 -Environment "staging"
```

## 🆘 Troubleshooting

### Issue: "Not authenticated to Azure"
**Solution:**
```powershell
az login
azd auth login
```

### Issue: "Resource group does not exist"
**Solution:**
```powershell
# Validate and create missing resources
.\scripts\prepare-deployment.ps1 -Environment "prod"
```

### Issue: "Configuration validation failed"
**Solution:**
```powershell
# Check configuration
.\scripts\config-loader.ps1 -Environment "prod" -ValidateOnly
```

### Issue: "Deployment token failed"
**Solution:**
```powershell
# Re-authenticate and retry
az login
.\scripts\quick-deploy.ps1 -Environment "prod"
```

## 📋 Next Steps

1. **🔧 Learn Configuration:** Read [Configuration Guide](CONFIGURATION-SYSTEM.md)
2. **📚 Explore Scripts:** Check [Scripts Reference](SCRIPTS-REFERENCE.md)
3. **🚀 Production Setup:** Review [Deployment Guide](DEPLOYMENT-REFERENCE.md)
4. **🔍 Troubleshooting:** Browse [Troubleshooting Guide](TROUBLESHOOTING.md)

## ✅ Success Checklist

- [ ] Azure CLI authenticated (`az account show`)
- [ ] Configuration file updated (`config\.env`)
- [ ] Deployment completed successfully
- [ ] Website accessible via provided URL
- [ ] All validation checks pass

**Congratulations! Your resume website is now live on Azure! 🎉**

---

**Need help?** Check the [Troubleshooting Guide](TROUBLESHOOTING.md) or open an issue.
