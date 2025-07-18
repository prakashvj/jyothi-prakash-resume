# 🚀 Complete New Site Setup Guide

## 🎯 **For Setting Up a Brand New Site**

This guide explains how to use our automation system to set up a completely new resume website from scratch, including Azure infrastructure and custom domain.

## 📋 **Prerequisites for New Site Setup**

### **1. Azure Setup**
```bash
# 1. Create Azure Service Principal
az ad sp create-for-rbac --name "resume-website-sp" --role contributor --scopes /subscriptions/{subscription-id}

# 2. Note down the output - you'll need this for GitHub secrets
{
  "clientId": "xxxx",
  "clientSecret": "xxxx", 
  "subscriptionId": "xxxx",
  "tenantId": "xxxx"
}
```

### **2. GitHub Secrets Configuration**
Add these secrets to your GitHub repository (`Settings` → `Secrets and variables` → `Actions`):

```
AZURE_CREDENTIALS = {
  "clientId": "your-client-id",
  "clientSecret": "your-client-secret", 
  "subscriptionId": "your-subscription-id",
  "tenantId": "your-tenant-id"
}

AZURE_SUBSCRIPTION_ID = "your-subscription-id"
AZURE_TENANT_ID = "your-tenant-id"
AZURE_RESOURCE_GROUP_NAME = "your-resume-RG"
AZURE_STATIC_WEB_APP_NAME = "your-resume-WebApp" 
AZURE_ENV_NAME = "prod"
AZURE_LOCATION = "eastasia"
```

## 🛠️ **Complete Setup Process**

### **Step 1: Fork/Clone Repository**
```bash
git clone https://github.com/prakashvj/jyothi-prakash-resume.git
cd jyothi-prakash-resume
```

### **Step 2: Configure Your Settings**
Edit `config/environments.json`:
```json
{
  "environments": {
    "prod": {
      "azure": {
        "subscriptionId": "${AZURE_SUBSCRIPTION_ID}",
        "tenantId": "${AZURE_TENANT_ID}",
        "location": "eastasia",
        "resourceGroup": "your-resume-RG",
        "staticWebAppName": "your-resume-WebApp",
        "customDomain": {
          "enabled": true,
          "friendlyName": "yourname",
          "domainType": "azurestaticapps",
          "fullDomain": "yourname.azurestaticapps.net"
        }
      }
    }
  }
}
```

### **Step 3: Update Your Resume Content**
Edit `src/index.html` with your information:
- Name and title
- Contact information
- Experience
- Skills
- Projects

### **Step 4: Run Complete Infrastructure Setup**

#### **Option A: Automated (Recommended)**
1. Push to main branch or trigger manually:
```bash
git add .
git commit -m "Initial setup with my resume"
git push origin main
```

2. Or trigger manually via GitHub Actions:
   - Go to `Actions` tab
   - Select "Full Infrastructure Deploy" 
   - Click "Run workflow"

#### **Option B: Manual Setup**
```bash
# 1. Provision infrastructure
azd provision

# 2. Deploy content  
azd deploy

# 3. Configure custom domain
.\scripts\configure-custom-domain.ps1 -Environment prod
```

## 🎯 **What Gets Created Automatically**

### **Azure Resources**
- ✅ **Resource Group** - Container for all resources
- ✅ **Azure Static Web App** - Hosts your resume website
- ✅ **Custom Domain** - yourname.azurestaticapps.net
- ✅ **SSL Certificate** - Automatic HTTPS
- ✅ **CDN** - Global content delivery

### **Deployment Pipeline**
- ✅ **GitHub Actions** - Automated CI/CD
- ✅ **Infrastructure as Code** - Bicep templates
- ✅ **Content Deployment** - Automatic on push
- ✅ **Custom Domain Setup** - Automated configuration

## 📊 **Expected Timeline**

| Step | Duration | What Happens |
|------|----------|--------------|
| Infrastructure | 3-5 min | Azure resources created |
| Content Deploy | 2-3 min | Website content uploaded |
| Custom Domain | 2-5 min | Domain configured + SSL |
| **Total** | **7-13 min** | **Complete live website** |

## 🔍 **Verification Steps**

### **1. Check Azure Portal**
- Resource Group created with your resources
- Static Web App running and healthy

### **2. Test Your Website**
```bash
# Test default URL
curl -I https://your-app-name.azurestaticapps.net

# Test custom domain  
curl -I https://yourname.azurestaticapps.net
```

### **3. Verify GitHub Actions**
- All workflows completed successfully
- Green checkmarks on commits

## 🎉 **Result**

You'll have a **production-ready resume website** with:
- ✅ Professional custom domain
- ✅ HTTPS/SSL security
- ✅ Global CDN performance
- ✅ Automated deployments
- ✅ Zero maintenance required

## 🔧 **Ongoing Updates**

After initial setup, any content changes:
1. Edit `src/index.html`
2. Commit and push to main
3. **Automatic deployment** - no manual steps needed!

---

**This system provides true infrastructure-as-code automation for complete new site deployment!** 🚀
