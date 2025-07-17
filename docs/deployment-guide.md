# Azure Static Web Apps Deployment Guide

This guide provides step-by-step instructions for deploying your resume website to Azure Static Web Apps using Azure Developer CLI (azd) and GitHub Actions.

## Prerequisites

Before you begin, ensure you have:

- **Azure subscription** with appropriate permissions
- **GitHub account** with repository access
- **Azure Developer CLI (azd)** installed locally
- **Git** configured with GitHub authentication

## Deployment Methods

### Method 1: Azure Developer CLI (Recommended)

The Azure Developer CLI provides the fastest way to deploy your resume website with infrastructure provisioning.

#### Step 1: Install Azure Developer CLI

```bash
# Windows (PowerShell)
winget install microsoft.azd

# macOS
brew tap azure/azd && brew install azd

# Linux
curl -fsSL https://aka.ms/install-azd.sh | bash
```

#### Step 2: Initialize and Deploy

1. **Navigate to your project directory:**
   ```bash
   cd C:\Users\jyothiv\source\repos\jyothi-prakash-resume
   ```

2. **Authenticate with Azure:**
   ```bash
   azd auth login
   ```

3. **Initialize the environment:**
   ```bash
   azd init
   ```
   - When prompted, select "Use code in the current directory"
   - Environment name: `jyothi-resume-prod` (or your preferred name)

4. **Deploy to Azure:**
   ```bash
   azd up
   ```
   - Select your Azure subscription
   - Choose deployment region (e.g., `East US 2` for cost optimization)
   - Confirm resource creation

#### Step 3: Verify Deployment

After successful deployment, azd will provide:
- **Website URL:** Your live resume website
- **Resource Group:** Azure resources created
- **GitHub Integration:** Automatic CI/CD setup

### Method 2: Manual Azure Portal Setup

If you prefer manual setup through the Azure Portal:

#### Step 1: Create Static Web App

1. Sign in to the [Azure Portal](https://portal.azure.com)
2. Click **Create a resource** → **Static Web App**
3. Configure basic settings:
   - **Subscription:** Your Azure subscription
   - **Resource Group:** Create new `rg-jyothi-resume-prod`
   - **Name:** `swa-jyothi-resume-prod`
   - **Plan type:** Free (for cost optimization)
   - **Region:** East US 2 (cost-effective)

#### Step 2: Connect GitHub Repository

1. **Source:** GitHub
2. **Organization:** Your GitHub username
3. **Repository:** `jyothi-prakash-resume`
4. **Branch:** `main`

#### Step 3: Build Configuration

1. **Build Presets:** Custom
2. **App location:** `/src`
3. **API location:** _(leave empty)_
4. **Output location:** `/src`

#### Step 4: Review and Create

1. Review all settings
2. Click **Review + create**
3. Click **Create** to deploy

## Environment-Specific Deployments

### Production Environment

**Environment Name:** `prod`
**Resource Naming:** `swa-jyothi-resume-prod`
**Domain:** Custom domain (optional) or Azure-provided URL

```bash
# Deploy to production
azd env set AZURE_ENV_NAME prod
azd up
```

### Pre-Production Environment (PPE)

**Environment Name:** `ppe`
**Resource Naming:** `swa-jyothi-resume-ppe`
**Domain:** Azure-provided staging URL

```bash
# Deploy to PPE
azd env set AZURE_ENV_NAME ppe
azd up
```

## CI/CD Pipeline (GitHub Actions)

The deployment automatically creates a GitHub Actions workflow at `.github/workflows/azure-static-web-apps-[app-name].yml`.

### Manual Workflow Creation

If you need to create the workflow manually:

1. Create `.github/workflows/deploy.yml`:

```yaml
name: Azure Static Web Apps CI/CD

on:
  push:
    branches: [ main ]
  pull_request:
    types: [opened, synchronize, reopened, closed]
    branches: [ main ]

jobs:
  build_and_deploy_job:
    if: github.event_name == 'push' || (github.event_name == 'pull_request' && github.event.action != 'closed')
    runs-on: ubuntu-latest
    name: Build and Deploy Job
    steps:
      - uses: actions/checkout@v3
        with:
          submodules: true
      - name: Build And Deploy
        id: builddeploy
        uses: Azure/static-web-apps-deploy@v1
        with:
          azure_static_web_apps_api_token: ${{ secrets.AZURE_STATIC_WEB_APPS_API_TOKEN }}
          repo_token: ${{ secrets.GITHUB_TOKEN }}
          action: "upload"
          app_location: "/src"
          output_location: "/src"

  close_pull_request_job:
    if: github.event_name == 'pull_request' && github.event.action == 'closed'
    runs-on: ubuntu-latest
    name: Close Pull Request Job
    steps:
      - name: Close Pull Request
        id: closepullrequest
        uses: Azure/static-web-apps-deploy@v1
        with:
          azure_static_web_apps_api_token: ${{ secrets.AZURE_STATIC_WEB_APPS_API_TOKEN }}
          action: "close"
```

### GitHub Secrets Configuration

Add these secrets to your GitHub repository:

1. Go to repository **Settings** → **Secrets and variables** → **Actions**
2. Add **AZURE_STATIC_WEB_APPS_API_TOKEN** (provided during Static Web App creation)

## Post-Deployment Configuration

### Custom Domain Setup (Optional)

1. In Azure Portal, navigate to your Static Web App
2. Go to **Custom domains**
3. Click **Add** → **Custom domain on Azure DNS** or **Custom domain on other DNS**
4. Follow the verification steps
5. Configure SSL certificate (automatically provided by Azure)

### Environment Variables

If your resume website requires environment variables:

1. In Azure Portal, go to your Static Web App
2. Navigate to **Configuration**
3. Add application settings as needed

### Monitoring and Analytics

1. **Application Insights:** Automatically integrated for monitoring
2. **GitHub Analytics:** Track repository activity
3. **Azure Monitor:** Set up alerts for website availability

## Cost Optimization

Your current configuration uses the **Free tier** of Azure Static Web Apps, which includes:

- ✅ **Free hosting** for static websites
- ✅ **100 GB bandwidth** per month
- ✅ **Automatic SSL certificates**
- ✅ **Global CDN** distribution
- ✅ **Custom domains** support
- ✅ **GitHub integration**

**Monthly Cost:** $0.00 (within free tier limits)

## Troubleshooting

### Common Issues

1. **Build Failures:**
   - Check the app location path (`/src`)
   - Verify file structure matches configuration
   - Review GitHub Actions logs

2. **404 Errors:**
   - Ensure `staticwebapp.config.json` is properly configured
   - Check route configurations
   - Verify file paths

3. **Security Headers:**
   - Headers are configured in `staticwebapp.config.json`
   - Test using [securityheaders.com](https://securityheaders.com)

4. **Performance Issues:**
   - Enable compression in static web app settings
   - Optimize images and assets
   - Use browser caching

### Useful Commands

```bash
# Check deployment status
azd show

# View deployment logs
azd logs

# Redeploy application
azd deploy

# Clean up resources
azd down

# List all environments
azd env list

# Switch environment
azd env select <environment-name>
```

### Support Resources

- [Azure Static Web Apps Documentation](https://docs.microsoft.com/azure/static-web-apps/)
- [Azure Developer CLI Documentation](https://docs.microsoft.com/azure/developer/azure-developer-cli/)
- [GitHub Actions Documentation](https://docs.github.com/actions)

## Security Considerations

Your deployment includes comprehensive security measures:

- **HTTPS enforcement** with automatic SSL certificates
- **Security headers** preventing common attacks
- **Content Security Policy** restricting resource loading
- **DDoS protection** through Azure's global network
- **Access controls** with configurable authentication

## Next Steps

After successful deployment:

1. **Test your website** across different devices and browsers
2. **Set up monitoring** for uptime and performance
3. **Configure custom domain** if desired
4. **Add Google Analytics** or other tracking (if needed)
5. **Set up alerts** for any issues

Your resume website is now live and accessible globally with enterprise-grade security and performance! 🚀
