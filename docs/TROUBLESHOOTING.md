# 🔧 Troubleshooting Guide

## 🎯 **What This Guide Does**
Provides **comprehensive problem resolution** for all common issues with GitHub Actions CI/CD deployment, Azure authentication, and Static Web Apps hosting. Essential for quickly diagnosing and fixing problems during setup and deployment.

## 🔧 **How It Does It**
- **Quick issue resolution table** for immediate problem identification
- **Step-by-step diagnostic procedures** with validation commands
- **GitHub Actions specific troubleshooting** with workflow debugging
- **Common error patterns** with specific solutions and explanations
- **Preventive maintenance tips** to avoid problems before they occur

## 📚 **Related Documentation**
- **[📖 Documentation Hub](README.md)** - Overview of all documentation
- **[🚀 Quick Start](QUICK-START.md)** - Basic setup to avoid common issues
- **[⚙️ Configuration System](CONFIGURATION-SYSTEM.md)** - Configuration-specific troubleshooting
- **[🔄 Clean Execution Flowchart](CLEAN-EXECUTION-FLOWCHART.md)** - Understanding the GitHub Actions workflow

---

Comprehensive troubleshooting guide for common issues with the GitHub Actions CI/CD deployment system.

## 🚨 Quick Issue Resolution

| Issue Type | Quick Fix | Where to Check |
|------------|-----------|----------------|
| Authentication | Check GitHub Secrets | Repository Settings > Secrets |
| Configuration | Validate `environments.json` | GitHub Actions logs |
| Deployment | Re-run workflow | GitHub Actions tab |
| Network | Check Azure Status | Azure Portal |
| Build | Check file syntax | GitHub Actions logs |

## 🔐 Authentication Issues

### Issue: "Azure authentication failed"

**Symptoms:**
```
❌ Error: OIDC authentication failed
❌ Azure CLI authentication failed
❌ No valid Azure subscription found
❌ Login failed for tenant
```

**Solutions:**

#### 1. OIDC Authentication (Recommended)
**Check GitHub Secrets:**
1. Go to your repository
2. Navigate to **Settings > Secrets and variables > Actions**
3. Verify these secrets exist:
   - `AZURE_CLIENT_ID`
   - `AZURE_TENANT_ID` 
   - `AZURE_SUBSCRIPTION_ID`

**Validate configuration:**
```json
// In config/environments.json
{
  "environments": {
    "prod": {
      "azure": {
        "auth": {
          "clientId": "${{ secrets.AZURE_CLIENT_ID }}",
          "tenantId": "${{ secrets.AZURE_TENANT_ID }}",
          "subscriptionId": "${{ secrets.AZURE_SUBSCRIPTION_ID }}"
        }
      }
    }
  }
}
```

#### 2. Interactive Authentication (Fallback)
If OIDC fails, GitHub Actions will fall back to interactive authentication:
1. Check GitHub Actions logs for authentication prompts
2. Ensure Azure subscription is active
3. Verify user has proper permissions

**Debug steps:**
```yaml
# Add this to your workflow for debugging
- name: Debug Authentication
  run: |
    echo "Checking Azure CLI version..."
    az --version
    echo "Checking current account..."
    az account show --output table
```

### Issue: "Permission denied errors"

**Symptoms:**
```
❌ Error: Insufficient privileges to complete the operation
❌ AuthorizationFailed: Principal does not have permission
❌ Forbidden: You don't have permission to access this resource
```

**Solutions:**

#### 1. Check Azure Permissions
Ensure your account has these roles:
- **Contributor** or **Owner** on the subscription
- **Static Web Apps Contributor** for hosting resources
- **Resource Group Contributor** for resource management

#### 2. Verify GitHub OIDC Setup
If using OIDC, ensure your Azure AD application has:
- Proper role assignments
- Correct federated credentials
- Valid service principal permissions

## ⚙️ Configuration Issues

### Issue: "Configuration file not found or invalid"

**Symptoms:**
```
❌ Error: Cannot find config/environments.json
❌ Invalid JSON format in configuration
❌ Missing required configuration properties
```

**Solutions:**

#### 1. Validate JSON Syntax
```bash
# Check JSON syntax locally
python -m json.tool config/environments.json

# Or using PowerShell
Get-Content config/environments.json | ConvertFrom-Json
```

#### 2. Check Required Properties
Minimum required configuration:
```json
{
  "environments": {
    "prod": {
      "azure": {
        "resourceGroup": "your-resource-group",
        "staticWebAppName": "your-app-name",
        "location": "eastus2"
      }
    }
  }
}
```

#### 3. Fix Common Configuration Errors
```json
// ❌ Wrong: Missing quotes
{
  environments: {
    prod: {
      azure: {
        resourceGroup: my-resource-group
      }
    }
  }
}

// ✅ Correct: Proper JSON format
{
  "environments": {
    "prod": {
      "azure": {
        "resourceGroup": "my-resource-group"
      }
    }
  }
}
```

### Issue: "Environment not found"

**Symptoms:**
```
❌ Error: Environment 'prod' not found in configuration
❌ Cannot load environment settings
❌ Invalid environment specified
```

**Solutions:**

#### 1. Check Environment Names
Ensure environment name matches exactly:
```bash
# Current branch triggers environment detection
# main branch = prod environment
# staging branch = staging environment
# other branches = dev environment
```

#### 2. Add Missing Environment
```json
{
  "environments": {
    "prod": { /* production config */ },
    "staging": { /* staging config */ },
    "dev": { /* development config */ }
  }
}
```

## 🚀 GitHub Actions Deployment Issues

### Issue: "Workflow fails to start"

**Symptoms:**
```
❌ Workflow not triggered on push
❌ Actions tab shows no workflows
❌ Workflow file not recognized
```

**Solutions:**

#### 1. Check Workflow File Location
Ensure the file is at:
```
.github/workflows/full-infrastructure-deploy.yml
```

#### 2. Validate YAML Syntax
```yaml
# Check for proper indentation and syntax
name: Full Infrastructure Deploy
on:
  push:
    branches: [main]
  pull_request:
    branches: [main]
```

#### 3. Check Permissions
Ensure repository has Actions enabled:
1. Go to repository **Settings**
2. Navigate to **Actions > General**
3. Select **Allow all actions and reusable workflows**

### Issue: "Deployment step fails"

**Symptoms:**
```
❌ Error: Resource group deployment failed
❌ Static Web App creation failed  
❌ Resource already exists with different configuration
```

**Solutions:**

#### 1. Resource Conflicts
```bash
# Check if resources already exist with different config
az group show --name your-resource-group
az staticwebapp show --name your-app-name --resource-group your-resource-group
```

#### 2. Force Recreate Resources
Add this to your workflow:
```yaml
- name: Deploy with Force Update
  run: |
    az deployment group create \
      --resource-group ${{ env.AZURE_RESOURCE_GROUP }} \
      --template-file infra/main.bicep \
      --mode Complete \
      --parameters @infra/main.parameters.json
```

#### 3. Clean Failed Deployments
```yaml
- name: Clean Failed Deployment
  run: |
    az deployment group list \
      --resource-group ${{ env.AZURE_RESOURCE_GROUP }} \
      --query "[?properties.provisioningState=='Failed'].name" \
      --output tsv | \
    xargs -I {} az deployment group delete \
      --resource-group ${{ env.AZURE_RESOURCE_GROUP }} \
      --name {}
```

### Issue: "Content deployment fails"

**Symptoms:**
```
❌ Error: Failed to upload website content
❌ SWA deployment failed
❌ Content validation failed
```

**Solutions:**

#### 1. Check Source Directory
Ensure your content is in the correct location:
```yaml
- name: Deploy Static Web App
  uses: Azure/static-web-apps-deploy@v1
  with:
    app_location: "src"  # Your content directory
    output_location: ""   # Build output (if any)
```

#### 2. Validate Content Structure
```
src/
├── index.html  # Required main file
├── css/
│   └── style.css
└── js/
    └── main.js
```

#### 3. Check File Permissions
```yaml
- name: Fix File Permissions
  run: |
    find src -type f -exec chmod 644 {} \;
    find src -type d -exec chmod 755 {} \;
```

## 🌐 Azure Static Web Apps Issues

### Issue: "Website not loading"

**Symptoms:**
```
❌ 404 Not Found
❌ SSL certificate errors
❌ DNS resolution failures
❌ Slow loading times
```

**Solutions:**

#### 1. Check Deployment Status
```bash
# Check deployment status in Azure Portal
az staticwebapp show \
  --name your-app-name \
  --resource-group your-resource-group \
  --query "repositoryUrl,defaultHostname,customDomains"
```

#### 2. Verify DNS Propagation
```bash
# Check DNS resolution
nslookup your-app-name.1.azurestaticapps.net
dig your-app-name.1.azurestaticapps.net
```

#### 3. SSL Certificate Issues
```yaml
- name: Check SSL Certificate
  run: |
    curl -I https://your-app-name.1.azurestaticapps.net
    openssl s_client -connect your-app-name.1.azurestaticapps.net:443 -servername your-app-name.1.azurestaticapps.net
```

### Issue: "Custom domain not working"

**Symptoms:**
```
❌ Custom domain shows as "Validating"
❌ DNS configuration errors
❌ SSL certificate provisioning failed
```

**Solutions:**

#### 1. Check DNS Configuration
```bash
# For CNAME record
dig CNAME your-domain.com

# For A record  
dig A your-domain.com
```

#### 2. Validate Domain Configuration
```json
{
  "features": {
    "customDomain": {
      "enabled": true,
      "domain": "your-domain.com",
      "validation": {
        "method": "dns-txt-token"
      }
    }
  }
}
```

## 🐛 Common Error Patterns

### GitHub Actions Specific Errors

#### Error: "Resource group not found"
```yaml
❌ Error: Resource group 'my-rg' could not be found
```
**Solution:**
```yaml
- name: Create Resource Group
  run: |
    az group create \
      --name ${{ env.AZURE_RESOURCE_GROUP }} \
      --location ${{ env.AZURE_LOCATION }}
```

#### Error: "Static Web App name already taken"
```yaml
❌ Error: The name 'myapp' is already taken
```
**Solution:**
Add unique suffix to your app name:
```json
{
  "azure": {
    "staticWebAppName": "myapp-${GITHUB_RUN_NUMBER}",
    "resourceGroup": "myapp-rg"
  }
}
```

#### Error: "Bicep template deployment failed"
```yaml
❌ Error: Template deployment failed with multiple errors
```
**Solution:**
```yaml
- name: Debug Bicep Template
  run: |
    az deployment group validate \
      --resource-group ${{ env.AZURE_RESOURCE_GROUP }} \
      --template-file infra/main.bicep \
      --parameters @infra/main.parameters.json
```

### Configuration Validation Errors

#### Error: "Invalid JSON in environments.json"
**Diagnostic:**
```bash
python -m json.tool config/environments.json
```

#### Error: "Missing required environment properties"
**Check required properties:**
```json
{
  "environments": {
    "prod": {
      "azure": {
        "resourceGroup": "required",
        "staticWebAppName": "required", 
        "location": "required"
      }
    }
  }
}
```

## 🔧 Debug Mode & Logging

### Enable Debug Mode in GitHub Actions
```yaml
- name: Enable Debug Logging
  run: |
    echo "ACTIONS_STEP_DEBUG=true" >> $GITHUB_ENV
    echo "ACTIONS_RUNNER_DEBUG=true" >> $GITHUB_ENV
```

### View Detailed Logs
```yaml
- name: Debug Azure CLI
  run: |
    az --version
    az account show --output table
    az group list --output table
    az staticwebapp list --output table
```

### Monitor Deployment Progress
```yaml
- name: Monitor Deployment
  run: |
    deployment_name=$(az deployment group list \
      --resource-group ${{ env.AZURE_RESOURCE_GROUP }} \
      --query "max_by([], &properties.timestamp).name" \
      --output tsv)
    
    az deployment group show \
      --resource-group ${{ env.AZURE_RESOURCE_GROUP }} \
      --name $deployment_name \
      --output table
```

## 📊 Performance Troubleshooting

### Issue: "Slow deployment times"

**Symptoms:**
```
⚠️ Deployment taking longer than 15 minutes
⚠️ GitHub Actions timeout
⚠️ Resource provisioning delays
```

**Solutions:**

#### 1. Optimize Workflow
```yaml
- name: Skip Unnecessary Steps
  if: github.event_name == 'pull_request'
  run: echo "Skipping full deployment for PR"

- name: Use Deployment Slots
  run: |
    # Deploy to staging slot first for PRs
    az staticwebapp environment set \
      --name ${{ env.STATIC_WEB_APP_NAME }} \
      --environment-name "preview-${{ github.event.number }}"
```

#### 2. Parallel Execution
```yaml
strategy:
  matrix:
    environment: [staging, prod]
    
steps:
- name: Deploy to ${{ matrix.environment }}
  run: |
    # Deploy environments in parallel
```

### Issue: "Resource limits exceeded"

**Symptoms:**
```
❌ Error: Quota exceeded for Static Web Apps
❌ Too many deployments in progress
❌ Rate limiting errors
```

**Solutions:**

#### 1. Check Azure Quotas
```bash
az staticwebapp list --output table
az account list-locations --output table
```

#### 2. Implement Deployment Queuing
```yaml
- name: Wait for Previous Deployment
  run: |
    while [[ $(az deployment group list \
      --resource-group ${{ env.AZURE_RESOURCE_GROUP }} \
      --query "length([?properties.provisioningState=='Running'])") -gt 0 ]]; do
      echo "Waiting for previous deployment to complete..."
      sleep 30
    done
```

## 🆘 Emergency Recovery

### Complete Environment Reset
```yaml
- name: Emergency Reset
  run: |
    # Delete and recreate resource group
    az group delete --name ${{ env.AZURE_RESOURCE_GROUP }} --yes --no-wait
    sleep 60
    az group create --name ${{ env.AZURE_RESOURCE_GROUP }} --location ${{ env.AZURE_LOCATION }}
    
    # Redeploy infrastructure
    az deployment group create \
      --resource-group ${{ env.AZURE_RESOURCE_GROUP }} \
      --template-file infra/main.bicep \
      --parameters @infra/main.parameters.json
```

### Rollback to Previous Version
```yaml
- name: Rollback Deployment
  run: |
    # Get previous successful deployment
    previous_deployment=$(az deployment group list \
      --resource-group ${{ env.AZURE_RESOURCE_GROUP }} \
      --query "reverse(sort_by([?properties.provisioningState=='Succeeded'], &properties.timestamp))[1].name" \
      --output tsv)
    
    # Rollback to previous state
    az deployment group create \
      --resource-group ${{ env.AZURE_RESOURCE_GROUP }} \
      --name "rollback-$(date +%s)" \
      --template-uri "$(az deployment group show \
        --resource-group ${{ env.AZURE_RESOURCE_GROUP }} \
        --name $previous_deployment \
        --query 'properties.templateLink.uri' \
        --output tsv)"
```

## 📞 Getting Additional Help

### Self-Diagnostic Checklist
- [ ] Configuration file exists and is valid JSON
- [ ] GitHub Secrets are properly configured
- [ ] Azure subscription is active and accessible
- [ ] Resource names are globally unique
- [ ] GitHub Actions workflow file exists in correct location
- [ ] Repository has Actions enabled

### Contact Information
If you've tried all troubleshooting steps:

1. **Check GitHub Actions logs** for specific error messages
2. **Review [Configuration System](CONFIGURATION-SYSTEM.md)** for setup validation
3. **Study [Clean Execution Flowchart](CLEAN-EXECUTION-FLOWCHART.md)** to understand the workflow
4. **Use GitHub Issues** on the repository for community support

---

**💡 Pro Tip:** Always check the GitHub Actions logs first - they contain detailed error information and are the best starting point for troubleshooting any deployment issues.
