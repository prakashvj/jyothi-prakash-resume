# ⚙️ Configuration System Guide

## 🎯 **What This Guide Does**
Provides **comprehensive understanding** of the centralized configuration system that powers GitHub Actions CI/CD deployments. Essential for managing production, staging, and development environments with consistent settings and security best practices.

## 🔧 **How It Does It**
- **Centralized configuration management** avoiding hardcoded values throughout the project
- **Multi-environment support** with inheritance and override capabilities
- **GitHub Actions integration** providing seamless configuration access across workflows
- **Security-first approach** with OIDC authentication and GitHub secrets management
- **Validation system** ensuring configuration integrity before deployment

## 📚 **Related Documentation**
- **[📖 Documentation Hub](../README.md)** - Overview of all documentation
- **[🚀 Quick Start](QUICK-START.md)** - Fast setup using this configuration system
- **[🔄 Clean Execution Flowchart](CLEAN-EXECUTION-FLOWCHART.md)** - How GitHub Actions uses configuration
- **[🔧 Troubleshooting](TROUBLESHOOTING.md)** - Configuration problem resolution

---

This project uses a **centralized configuration system** that allows you to manage multiple environments (prod, staging, dev) with consistent settings through GitHub Actions automation.

## 🏗️ Configuration Architecture

```
config/
├── environments.json           # Environment-specific settings (main config)
├── deployment-staging.yaml     # Staging deployment overrides
├── deployment.yaml            # Production deployment settings
├── validation.yaml            # Validation rules
└── config.json               # Legacy global configuration
```

## 📋 Core Components

### 1. Environment Configuration (`environments.json`)

**Purpose:** Defines environment-specific Azure resource settings for GitHub Actions

```json
{
  "environments": {
    "prod": {
      "azure": {
        "resourceGroup": "jyothi-resume-RG",
        "staticWebAppName": "jyothiventrapragada-resume",
        "location": "eastasia",
        "auth": {
          "clientId": "your-azure-client-id",
          "tenantId": "your-azure-tenant-id",
          "subscriptionId": "your-azure-subscription-id"
        }
      },
      "deployment": {
        "validateDependencies": true,
        "skipExistingResources": true,
        "enablePreview": false
      },
      "features": {
        "customDomain": {
          "enabled": false,
          "domain": "resume.yourdomain.com"
        },
        "analytics": {
          "enabled": false,
          "provider": "google"
        }
      }
    },
    "staging": {
      "azure": {
        "resourceGroup": "jyothi-resume-staging-RG",
        "staticWebAppName": "jyothiventrapragada-resume-staging",
        "location": "eastus2"
      },
      "deployment": {
        "validateDependencies": true,
        "skipExistingResources": false,
        "enablePreview": true
      }
    }
  }
}
```

### 2. GitHub Actions Integration

**Purpose:** GitHub Actions workflow automatically reads from `environments.json`

```yaml
# .github/workflows/full-infrastructure-deploy.yml
- name: Load Environment Configuration
  run: |
    $config = Get-Content config/environments.json | ConvertFrom-Json
    $envConfig = $config.environments.prod
    
    echo "AZURE_RESOURCE_GROUP=$($envConfig.azure.resourceGroup)" >> $env:GITHUB_ENV
    echo "STATIC_WEB_APP_NAME=$($envConfig.azure.staticWebAppName)" >> $env:GITHUB_ENV
    echo "AZURE_LOCATION=$($envConfig.azure.location)" >> $env:GITHUB_ENV
```

### 3. Authentication Configuration

#### Option A: OIDC Authentication (Recommended)
Configure in `environments.json`:
```json
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

#### Option B: Interactive Authentication
Leave auth section empty and GitHub Actions will prompt for authentication.

## 🔐 Security Configuration

### GitHub Secrets Management
Configure these secrets in your GitHub repository:

| Secret Name | Description | Required |
|-------------|-------------|----------|
| `AZURE_CLIENT_ID` | Azure AD Application Client ID | Optional (for OIDC) |
| `AZURE_TENANT_ID` | Azure AD Tenant ID | Optional (for OIDC) |
| `AZURE_SUBSCRIPTION_ID` | Azure Subscription ID | Optional (for OIDC) |

### Setting GitHub Secrets
1. Go to your GitHub repository
2. Navigate to **Settings > Secrets and variables > Actions**
3. Click **New repository secret**
4. Add each required secret

## 🌍 Multi-Environment Management

### Environment Inheritance
Environments inherit from base configuration and can override specific values:

```json
{
  "environments": {
    "base": {
      "azure": {
        "location": "eastus2",
        "sku": "Free"
      }
    },
    "prod": {
      "extends": "base",
      "azure": {
        "resourceGroup": "prod-resume-RG",
        "staticWebAppName": "prod-resume-app"
      }
    },
    "staging": {
      "extends": "base", 
      "azure": {
        "resourceGroup": "staging-resume-RG",
        "staticWebAppName": "staging-resume-app",
        "location": "westus2"  // Override base location
      }
    }
  }
}
```

### Deploying to Different Environments
```bash
# Deploy to production (default)
git push origin main

# Deploy to staging
git push origin staging

# Deploy to development
git push origin dev
```

## ⚙️ Configuration Options

### Azure Resource Settings
```json
{
  "azure": {
    "resourceGroup": "string",        // Azure Resource Group name
    "staticWebAppName": "string",     // Static Web App name
    "location": "string",             // Azure region (eastus, westus2, etc.)
    "sku": "Free|Standard",           // Static Web App pricing tier
    "customDomain": {
      "enabled": false,               // Enable custom domain
      "domain": "example.com"         // Custom domain name
    }
  }
}
```

### Deployment Settings
```json
{
  "deployment": {
    "validateDependencies": true,     // Validate before deployment
    "skipExistingResources": true,    // Skip if resources exist
    "enablePreview": false,           // Enable preview deployments
    "timeout": 1800,                  // Deployment timeout (seconds)
    "retryAttempts": 3               // Retry failed deployments
  }
}
```

### Feature Flags
```json
{
  "features": {
    "customDomain": {
      "enabled": false,               // Toggle custom domain
      "domain": "resume.example.com"
    },
    "analytics": {
      "enabled": false,               // Toggle analytics
      "provider": "google",           // Analytics provider
      "trackingId": "GA_TRACKING_ID"
    },
    "seo": {
      "enabled": true,                // SEO optimizations
      "sitemap": true,                // Generate sitemap
      "robots": true                  // Generate robots.txt
    }
  }
}
```

## 🔧 Configuration Validation

### GitHub Actions Validation
The workflow automatically validates configuration:

```yaml
- name: Validate Configuration
  run: |
    # Check required fields
    $config = Get-Content config/environments.json | ConvertFrom-Json
    if (-not $config.environments.prod) {
      throw "Production environment configuration missing"
    }
    
    # Validate Azure settings
    $azureConfig = $config.environments.prod.azure
    if (-not $azureConfig.resourceGroup) {
      throw "Resource group name is required"
    }
```

### Manual Validation
```bash
# Validate configuration locally
pwsh -Command "
  $config = Get-Content config/environments.json | ConvertFrom-Json;
  Write-Host 'Configuration is valid' -ForegroundColor Green
"
```

## 📊 Configuration Examples

### Minimal Configuration
```json
{
  "environments": {
    "prod": {
      "azure": {
        "resourceGroup": "my-resume-RG",
        "staticWebAppName": "my-resume-app",
        "location": "eastus2"
      }
    }
  }
}
```

### Full Production Configuration
```json
{
  "environments": {
    "prod": {
      "azure": {
        "resourceGroup": "prod-resume-RG",
        "staticWebAppName": "prod-resume-app",
        "location": "eastus2",
        "sku": "Standard",
        "auth": {
          "clientId": "${{ secrets.AZURE_CLIENT_ID }}",
          "tenantId": "${{ secrets.AZURE_TENANT_ID }}",
          "subscriptionId": "${{ secrets.AZURE_SUBSCRIPTION_ID }}"
        }
      },
      "deployment": {
        "validateDependencies": true,
        "skipExistingResources": true,
        "enablePreview": false,
        "timeout": 1800
      },
      "features": {
        "customDomain": {
          "enabled": true,
          "domain": "resume.example.com"
        },
        "analytics": {
          "enabled": true,
          "provider": "google",
          "trackingId": "GA_TRACKING_ID"
        }
      }
    }
  }
}
```

## 🚀 GitHub Actions Integration

### Accessing Configuration in Workflows
```yaml
- name: Load Configuration
  id: config
  run: |
    $config = Get-Content config/environments.json | ConvertFrom-Json
    $envConfig = $config.environments.prod
    
    echo "resource-group=$($envConfig.azure.resourceGroup)" >> $env:GITHUB_OUTPUT
    echo "webapp-name=$($envConfig.azure.staticWebAppName)" >> $env:GITHUB_OUTPUT
    echo "location=$($envConfig.azure.location)" >> $env:GITHUB_OUTPUT

- name: Deploy Infrastructure
  uses: azure/arm-deploy@v1
  with:
    resourceGroupName: ${{ steps.config.outputs.resource-group }}
    template: infra/main.bicep
    parameters: |
      staticWebAppName=${{ steps.config.outputs.webapp-name }}
      location=${{ steps.config.outputs.location }}
```

### Environment-Specific Workflows
```yaml
# Deploy based on branch
- name: Determine Environment
  id: env
  run: |
    if ($env:GITHUB_REF -eq "refs/heads/main") {
      echo "environment=prod" >> $env:GITHUB_OUTPUT
    } elseif ($env:GITHUB_REF -eq "refs/heads/staging") {
      echo "environment=staging" >> $env:GITHUB_OUTPUT
    } else {
      echo "environment=dev" >> $env:GITHUB_OUTPUT
    }

- name: Load Environment Config
  run: |
    $config = Get-Content config/environments.json | ConvertFrom-Json
    $envConfig = $config.environments.${{ steps.env.outputs.environment }}
    # Use environment-specific configuration
```

## 🔄 Configuration Updates

### Updating Configuration
1. **Edit `config/environments.json`** with your changes
2. **Commit and push** to trigger deployment with new settings
3. **Monitor GitHub Actions** for validation and deployment status

### Best Practices
- ✅ **Always validate** configuration changes locally first
- ✅ **Use descriptive names** for resources and environments
- ✅ **Keep secrets in GitHub Secrets**, not in configuration files
- ✅ **Test in staging** before deploying to production
- ✅ **Document changes** in commit messages

## 🆘 Troubleshooting Configuration

### Common Issues

#### Configuration Not Loading
- Check JSON syntax in `environments.json`
- Verify file encoding (UTF-8 without BOM)
- Ensure proper indentation and quotes

#### Authentication Failures  
- Verify GitHub Secrets are correctly configured
- Check Azure subscription permissions
- Validate client ID, tenant ID, and subscription ID

#### Resource Deployment Failures
- Verify resource names are globally unique
- Check Azure region availability for Static Web Apps
- Ensure resource group naming follows Azure conventions

### Debug Configuration
```bash
# View current configuration
cat config/environments.json

# Validate JSON syntax
python -m json.tool config/environments.json

# Test PowerShell parsing
pwsh -Command "Get-Content config/environments.json | ConvertFrom-Json | ConvertTo-Json -Depth 10"
```

## 📚 Advanced Configuration

### Custom Deployment Scripts
Create environment-specific deployment overrides:

```yaml
# config/deployment-staging.yaml
override:
  skipTests: true
  enableDebug: true
  deploymentSlots: false
```

### Configuration Templates
Use templates for consistent environment setup:

```json
{
  "templates": {
    "azureDefaults": {
      "location": "eastus2",
      "sku": "Free",
      "deployment": {
        "validateDependencies": true,
        "skipExistingResources": true
      }
    }
  },
  "environments": {
    "prod": {
      "extends": "azureDefaults",
      "azure": {
        "resourceGroup": "prod-resume-RG"
      }
    }
  }
}
```

---

**🎯 Next Steps:**
- **[Quick Start](QUICK-START.md)** - Deploy using this configuration system
- **[Clean Execution Flowchart](CLEAN-EXECUTION-FLOWCHART.md)** - See how GitHub Actions uses configuration
- **[Troubleshooting](TROUBLESHOOTING.md)** - Resolve configuration issues

**💡 Pro Tip:** Start with minimal configuration and gradually add features as needed. The GitHub Actions workflow will validate your configuration and provide helpful error messages.
