# 🚀 Quick Start Guide

## 🎯 **What This Guide Does**
Gets your resume website **deployed to Azure in 5 minutes** with minimal configuration. Perfect for first-time users who want to see immediate results through GitHub Actions automation.

## 🔧 **How It Does It**
- **GitHub Actions automation** that handles infrastructure and content deployment
- **Zero-command deployment** triggered by Git push to main branch
- **Built-in validation** to catch issues before deployment starts
- **Live URL generation** so you can see your website immediately
- **Quick troubleshooting** for common first-time setup issues

## 📚 **Related Documentation**
- **[📖 Documentation Hub](../README.md)** - Overview of all documentation
- **[⚙️ Configuration System](CONFIGURATION-SYSTEM.md)** - Deep dive into configuration management
- **[🔄 Clean Execution Flowchart](CLEAN-EXECUTION-FLOWCHART.md)** - Complete GitHub Actions workflow
- **[🔧 Troubleshooting](TROUBLESHOOTING.md)** - Solutions for common issues

---

Get your resume website deployed to Azure in 5 minutes!

## Prerequisites

- **Azure Account** with active subscription
- **GitHub Account** for repository hosting and GitHub Actions
- **Git** for repository management
- **Browser** for viewing your deployed website

## Step 1: Fork and Clone

### 1.1 Fork Repository
1. Go to [jyothi-prakash-resume repository](https://github.com/prakashvj/jyothi-prakash-resume)
2. Click **Fork** button (top right)
3. Create fork in your GitHub account

### 1.2 Clone Your Fork
```bash
git clone https://github.com/YOUR-USERNAME/jyothi-prakash-resume.git
cd jyothi-prakash-resume
```

## Step 2: Configure Azure Authentication (Optional)

### 2.1 Option A: OIDC Authentication (Recommended)
Edit `config/environments.json` with your Azure details:
```json
{
  "environments": {
    "prod": {
      "azure": {
        "auth": {
          "clientId": "your-azure-client-id",
          "tenantId": "your-azure-tenant-id",
          "subscriptionId": "your-azure-subscription-id"
        }
      }
    }
  }
}
```

### 2.2 Option B: Skip Configuration
GitHub Actions will use interactive authentication if OIDC is not configured.

## Step 3: Deploy to Azure

### 3.1 Push to Deploy
```bash
# Add your changes
git add .
git commit -m "Initial setup: Configure my resume website"

# Push triggers automatic deployment
git push origin main
```

### 3.2 Monitor Deployment
1. Go to your GitHub repository
2. Click **Actions** tab
3. Watch the "Full Infrastructure Deploy" workflow
4. Wait 8-12 minutes for complete deployment

## Step 4: Verify Your Website

### 4.1 Get Your URL
After successful deployment, check the GitHub Actions output for your live URL:
```
✅ Website URL: https://your-site-name.1.azurestaticapps.net
```

### 4.2 Test Your Website
1. Open the URL in your browser
2. Verify the resume content displays correctly
3. Test print layout (Ctrl+P or Cmd+P)

## 🎉 Success! Your Website is Live

**What Just Happened:**
- ✅ GitHub Actions automatically deployed your infrastructure
- ✅ Azure Static Web App was created
- ✅ Your resume website is now live
- ✅ SSL certificate was automatically provisioned
- ✅ Content delivery is globally distributed

## 📝 Customizing Your Resume

### Update Content
```bash
# Edit your resume content
# Modify src/index.html with your details

# Commit and push to deploy changes
git add src/index.html
git commit -m "Update: Add my professional experience"
git push origin main
```

### Update Styling
```bash
# Customize the design
# Modify src/css/style.css

# Deploy your style changes
git add src/css/style.css
git commit -m "Style: Update color scheme"
git push origin main
```

## 🔄 Understanding the Workflow

### What Happens on Each Push:
1. **Validation:** Configuration and file validation
2. **Authentication:** Azure authentication (OIDC or Interactive)
3. **Resource Check:** Smart detection of existing infrastructure
4. **Infrastructure:** Deploy Bicep templates if needed (8-12 min)
5. **Content:** Deploy website content (2-4 min)
6. **Verification:** Post-deployment validation
7. **URL Output:** Live website URL provided

### Subsequent Updates:
- **Content changes only:** 2-4 minutes
- **Infrastructure exists:** Skip infrastructure deployment
- **No changes detected:** Skip deployment entirely

## 🛠️ Advanced Configuration

### Environment Variables (Optional)
Configure environment-specific settings in `config/environments.json`:

```json
{
  "environments": {
    "prod": {
      "azure": {
        "resourceGroup": "my-resume-RG",
        "staticWebAppName": "my-resume-app",
        "location": "eastus2",
        "customDomain": {
          "enabled": false,
          "domain": "resume.mydomain.com"
        }
      }
    }
  }
}
```

### GitHub Secrets (for OIDC)
Configure these secrets in your GitHub repository settings:
- `AZURE_CLIENT_ID`
- `AZURE_TENANT_ID` 
- `AZURE_SUBSCRIPTION_ID`

## 🆘 Troubleshooting

### Common Issues

#### Deployment Fails
1. Check GitHub Actions logs
2. Verify Azure subscription is active
3. Ensure repository secrets are configured correctly

#### Website Not Loading
1. Check Azure Static Web Apps status in Azure Portal
2. Verify DNS propagation (may take up to 48 hours)
3. Clear browser cache and try again

#### Authentication Errors
1. Verify Azure credentials in `config/environments.json`
2. Check GitHub repository secrets
3. Ensure Azure subscription has proper permissions

### Getting Help
- 🔄 **Workflow Questions:** [Clean Execution Flowchart](CLEAN-EXECUTION-FLOWCHART.md)
- 🔧 **Deployment Issues:** [Troubleshooting Guide](TROUBLESHOOTING.md)
- ⚙️ **Configuration Help:** [Configuration System](CONFIGURATION-SYSTEM.md)

## 🎯 Next Steps

### For Regular Updates:
```bash
# Make changes to your resume
git checkout -b feature/update-experience
# Edit src/index.html
git add . && git commit -m "Update: Add new job experience"
git push origin feature/update-experience
# Create Pull Request, merge triggers deployment
```

### For Advanced Users:
- **[Configuration System](CONFIGURATION-SYSTEM.md)** - Multi-environment setup
- **[Complete Execution Flow](COMPLETE-EXECUTION-FLOW.md)** - Detailed pipeline documentation
- **[Troubleshooting](TROUBLESHOOTING.md)** - Advanced problem resolution

---

**🚀 Congratulations! Your professional resume website is now live on Azure with automated GitHub Actions deployment!**

**Next:** Check out the [Configuration System](CONFIGURATION-SYSTEM.md) to understand how to customize environments and deployment settings.
