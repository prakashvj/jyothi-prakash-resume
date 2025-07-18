# 🧠 Intelligent Deployment Workflow

## 🎯 **Smart Resource Detection & Incremental Deployment**

The enhanced GitHub Actions workflow now includes intelligent resource detection that automatically determines whether to provision new infrastructure or just deploy content updates.

## 🔍 **How It Works**

### **Phase 1: Resource Detection**
```bash
🔍 Checking existing Azure resources...
├── Check if Resource Group exists
├── Check if Static Web App exists
└── Set deployment strategy accordingly
```

### **Phase 2: Conditional Deployment**

#### **Scenario A: New Site Setup (No Resources Exist)**
```yaml
Workflow Path: FULL INFRASTRUCTURE DEPLOYMENT
├── 🏗️ Provision Azure infrastructure (AZD)
├── 📦 Deploy application content (AZD)
├── 🌐 Configure custom domain
└── ✅ Complete new site ready
```

#### **Scenario B: Content Updates (Resources Exist)**
```yaml
Workflow Path: CONTENT-ONLY DEPLOYMENT
├── ⏭️ Skip infrastructure provisioning
├── 📦 Deploy content only (Fast)
├── 🌐 Update custom domain (if needed)
└── ✅ Updated site ready
```

## 🚀 **Performance Benefits**

### **For Existing Sites:**
- **⚡ Faster Deployments** - Skips infrastructure checks (2-3 minutes vs 8-10 minutes)
- **💰 Cost Efficient** - No unnecessary Azure resource operations
- **🔄 Safer Updates** - Won't accidentally modify existing infrastructure
- **📦 Content Focus** - Direct content deployment to existing resources

### **For New Sites:**
- **🏗️ Full Setup** - Complete infrastructure provisioning
- **🌐 Custom Domain** - Automatic configuration
- **⚙️ Zero Config** - Everything created from scratch
- **✅ Production Ready** - Live site in one workflow run

## 📊 **Deployment Decision Matrix**

| Condition | Resource Group | Static Web App | Action Taken | Duration |
|-----------|----------------|----------------|--------------|----------|
| **New Site** | ❌ Not Found | ❌ Not Found | Full Infrastructure | 8-10 min |
| **Partial Setup** | ✅ Exists | ❌ Not Found | Full Infrastructure | 6-8 min |
| **Existing Site** | ✅ Exists | ✅ Exists | Content Only | 2-3 min |
| **Force Rebuild** | ✅ Exists | ✅ Exists | Manual Trigger | 8-10 min |

## 🎛️ **Manual Override Options**

### **Force Full Infrastructure (Manual Trigger)**
```bash
# Via GitHub Actions UI
Go to: Actions → Full Infrastructure Deploy → Run workflow
```

### **Force Content Only**
```bash
# Push to main with existing resources
git push origin main
```

## 🔧 **Configuration Requirements**

### **For New Sites (Full Infrastructure):**
Required GitHub Secrets:
```yaml
AZURE_CREDENTIALS          # Service Principal
AZURE_SUBSCRIPTION_ID       # Azure Subscription
AZURE_TENANT_ID            # Azure Tenant
AZURE_ENV_NAME             # Environment name (optional)
AZURE_LOCATION             # Azure region (optional)
```

### **For Existing Sites (Content Only):**
Required GitHub Secrets:
```yaml
AZURE_STATIC_WEB_APPS_API_TOKEN  # From existing Static Web App
GITHUB_TOKEN                     # Automatic
```

## 🎯 **Best Practices**

### **Development Workflow:**
1. **Content Changes** → Push to main → Content-only deployment (Fast)
2. **Infrastructure Changes** → Manual workflow trigger → Full deployment
3. **New Features** → Feature branch → PR → Staging → Merge → Production

### **Production Considerations:**
- **✅ Incremental Updates** - Faster feedback cycles
- **✅ Resource Stability** - Existing infrastructure preserved
- **✅ Rollback Safety** - Easy content rollbacks without infrastructure impact
- **✅ Cost Optimization** - Minimal Azure API calls for content updates

## 📈 **Monitoring & Validation**

The workflow provides clear indicators of which path was taken:

### **Full Infrastructure Output:**
```
📊 Full Infrastructure Deployment Summary:
├── 🏗️ Infrastructure: Provisioned
├── 📦 Content: Deployed
├── Resource Group: jyothi-resume-RG
├── Static Web App: jyothi-resume-WebApp
```

### **Content-Only Output:**
```
📊 Content-Only Deployment Summary:
├── ⏭️ Infrastructure: Skipped (already exists)
├── 📦 Content: Updated
├── Resource Group: jyothi-resume-RG
├── Static Web App: jyothi-resume-WebApp
```

This intelligent workflow ensures optimal deployment performance while maintaining full automation capabilities for both new site setup and ongoing content updates.
