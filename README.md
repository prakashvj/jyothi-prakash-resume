# 🏠 Jyothi Prakash Resume Website

Professional re## 📚 Documentation

| Document | Description | Use Case |
|----------|-------------|----------|
| [🚀 Quick Start](docs/QUICK-START.md) | Get started in 5 minutes | First-time setup |
| [⚙️ Configuration System](docs/CONFIGURATION-SYSTEM.md) | Environment and configuration management | Understanding the config system |
| [📜 Scripts Reference](docs/SCRIPTS-REFERENCE.md) | Complete script documentation | Script usage and parameters |
| [🚀 Deployment Reference](docs/DEPLOYMENT-REFERENCE.md) | Deployment strategies and best practices | Advanced deployment scenarios |
| [🔄 PR Workflow Guide](docs/PR-WORKFLOW-GUIDE.md) | Professional Pull Request workflow | Team collaboration & code quality |
| [🔧 Troubleshooting](docs/TROUBLESHOOTING.md) | Common issues and solutions | Problem resolution |ite for **Jyothi Prakash Ventrapragada**, Senior Site Reliability Engineering Manager, showcasing 25+ years of technology experience with Azure cloud environments, database architecture, and large-scale distributed systems.

## 🌐 Live Website

**Production URL:** https://mango-water-0502ea200.1.azurestaticapps.net

## 🚀 Quick Start (5 minutes)

### 1. Clone and Setup
```bash
git clone https://github.com/your-username/jyothi-prakash-resume.git
cd jyothi-prakash-resume
```

### 2. Configure Environment
```powershell
# Copy environment template
cp config\.env.template config\.env

# Edit with your Azure details
notepad config\.env
```

### 3. Deploy to Azure
```powershell
# One-command deployment (creates everything)
.\scripts\deploy-one-command.ps1 -Environment "prod"
```

**� That's it! Your resume website is now live on Azure!**

👉 **New to the project? Start with [Quick Start Guide](docs/QUICK-START.md)** 👈

## �🏗️ Architecture

- **Frontend:** Static HTML with modern CSS and JavaScript
- **Hosting:** Azure Static Web Apps (Free Tier)
- **Infrastructure:** Bicep (Infrastructure as Code)
- **Configuration:** Centralized multi-environment system
- **Deployment:** PowerShell automation scripts

## 📋 Key Features

- ✅ **Print-Optimized:** Fits exactly 3 pages when printed
- ✅ **Responsive Design:** Mobile-friendly professional layout
- ✅ **Fast Loading:** Single HTML file with embedded assets
- ✅ **Multi-Environment:** Support for prod, staging, dev environments
- ✅ **One-Command Deployment:** Complete automation
- ✅ **Configuration Management:** Centralized settings system
- ✅ **Comprehensive Validation:** Pre and post-deployment checks

## 📚 Documentation

| Document | Description | Use Case |
|----------|-------------|----------|
| [🚀 Quick Start](docs/QUICK-START.md) | Get started in 5 minutes | First-time setup |
| [⚙️ Configuration System](docs/CONFIGURATION-SYSTEM.md) | Environment and configuration management | Understanding the config system |
| [� Scripts Reference](docs/SCRIPTS-REFERENCE.md) | Complete script documentation | Script usage and parameters |
| [🚀 Deployment Reference](docs/DEPLOYMENT-REFERENCE.md) | Deployment strategies and best practices | Advanced deployment scenarios |
| [🔧 Troubleshooting](docs/TROUBLESHOOTING.md) | Common issues and solutions | Problem resolution |

## ⚡ Quick Commands

```powershell
# 🚀 First-time deployment (creates everything)
.\scripts\deploy-one-command.ps1 -Environment "prod"

# ⚡ Content updates only (faster)
.\scripts\quick-deploy.ps1 -Environment "prod"

# ✅ Validate deployment health
.\scripts\validate-deployment.ps1 -Environment "prod"

# ⚙️ Test configuration
.\scripts\config-loader.ps1 -Environment "prod" -ValidateOnly

# 🔍 Essential validation checks
.\scripts\validate-essentials.ps1 -Environment "prod" -Quick
```

## 🎯 Common Workflows

### First-Time Setup
```powershell
# 1. Copy environment template
cp config\.env.template config\.env

# 2. Edit with your Azure details
notepad config\.env

# 3. Deploy everything
.\scripts\deploy-one-command.ps1 -Environment "prod"
```

### Regular Updates
```powershell
# Create feature branch for changes
git checkout -b feature/update-resume-content

# Make your changes to src/index.html or src/css/style.css

# Commit and push
git add .
git commit -m "Update: Add new project experience"
git push origin feature/update-resume-content

# Create Pull Request on GitHub
# After review and approval, merge triggers automatic deployment
```

### Professional PR Workflow
👉 **[Complete PR Workflow Guide](docs/PR-WORKFLOW-GUIDE.md)** for team collaboration

### Troubleshooting
```powershell
# Validate setup
.\scripts\validate-essentials.ps1 -Environment "prod" -Detailed

# Check configuration
.\scripts\config-loader.ps1 -Environment "prod" -ShowAll
```

## 🔧 Configuration System

This project uses a **centralized configuration system** supporting multiple environments:

### Configuration Files
- `config/environments.json` - Environment-specific settings
- `config/.env` - Local overrides and secrets (git-ignored)
- `scripts/ConfigModule.psm1` - PowerShell configuration functions

### Multi-Environment Support
```json
{
  "environments": {
    "prod": {
      "azure": {
        "resourceGroup": "jyothi-resume-RG",
        "staticWebAppName": "jyothi-resume-WebApp",
        "location": "eastasia"
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

👉 **[Complete Configuration Guide](docs/CONFIGURATION-SYSTEM.md)** 👈

## 📁 Project Structure

```
jyothi-prakash-resume/
├── 📁 src/                          # Website source code
│   └── index.html                   # Main resume website
├── 📁 config/                       # Configuration management
│   ├── .env.template                # Environment template
│   ├── environments.json            # Environment settings
│   └── settings.ini                 # Legacy settings
├── 📁 scripts/                      # Deployment automation
│   ├── deploy-one-command.ps1       # Full deployment
│   ├── quick-deploy.ps1             # Content-only deployment
│   ├── validate-deployment.ps1      # Health validation
│   ├── validate-essentials.ps1      # Essential checks
│   ├── config-loader.ps1            # Configuration testing
│   ├── prepare-deployment.ps1       # Deployment preparation
│   └── ConfigModule.psm1            # Configuration functions
├── 📁 infra/                        # Infrastructure as Code
│   ├── main.bicep                   # Main Bicep template
│   ├── main.parameters.json         # Deployment parameters
│   └── staticwebapp.bicep           # Static Web App module
├── 📁 docs/                         # Documentation
│   ├── QUICK-START.md               # 5-minute setup guide
│   ├── CONFIGURATION-SYSTEM.md      # Config system guide
│   ├── SCRIPTS-REFERENCE.md         # Script documentation
│   ├── DEPLOYMENT-REFERENCE.md      # Deployment strategies
│   └── TROUBLESHOOTING.md           # Problem resolution
└── 📁 logs/                         # Deployment logs
```

## 🚀 Available Scripts

| Script | Purpose | Usage |
|--------|---------|-------|
| `deploy-one-command.ps1` | Complete deployment | First-time setup, infrastructure changes |
| `quick-deploy.ps1` | Content-only deployment | Regular website updates |
| `validate-deployment.ps1` | Health & performance checks | Post-deployment validation |
| `validate-essentials.ps1` | Essential pre-checks | Pre-deployment validation |
| `config-loader.ps1` | Configuration management | Testing and debugging |
| `prepare-deployment.ps1` | Deployment preparation | Dependency validation |

## 🌍 Multi-Environment Deployment

Deploy to different environments:

```powershell
# Production
.\scripts\deploy-one-command.ps1 -Environment "prod"

# Staging
.\scripts\deploy-one-command.ps1 -Environment "staging"

# Development
.\scripts\deploy-one-command.ps1 -Environment "dev"
```

## 💰 Cost & Performance

- **Azure Static Web Apps Free Tier:** $0/month
- **100GB bandwidth included**
- **Page Load Speed:** < 2 seconds
- **Lighthouse Score:** 95+ (Performance, Accessibility, SEO)
- **Print Optimization:** Exactly 3 pages when printed

## 🔒 Security Features

- ✅ **HTTPS Only:** Enforced SSL/TLS encryption
- ✅ **Managed Certificates:** Automatic SSL provisioning
- ✅ **No Backend Dependencies:** Reduced attack surface
- ✅ **Configuration Security:** Secrets in git-ignored files
- ✅ **Azure Security:** Built-in Azure protection features

## 🛠️ Technologies

- **Frontend:** HTML5, CSS3, JavaScript (ES6+)
- **Fonts:** Google Fonts (Playfair Display, Source Sans Pro)
- **Infrastructure:** Azure Bicep
- **Automation:** PowerShell scripts
- **Deployment:** Azure Static Web Apps
- **Configuration:** JSON + Environment variables

## 🔧 Development

### Local Testing
```bash
# Open website locally
start src/index.html  # Windows
open src/index.html   # macOS
```

### Print Layout Testing
```javascript
// Test print layout in browser console
window.print();
```

### Making Changes
1. Edit `src/index.html` for content updates
2. Test locally in browser
3. Use `quick-deploy.ps1` for fast updates
4. Validate with `validate-deployment.ps1`

## 🆘 Need Help?

- 🚀 **New User?** Start with [Quick Start Guide](docs/QUICK-START.md)
- ⚙️ **Configuration Issues?** Check [Configuration System](docs/CONFIGURATION-SYSTEM.md)
- 🔧 **Deployment Problems?** See [Troubleshooting Guide](docs/TROUBLESHOOTING.md)
- 📜 **Script Questions?** Review [Scripts Reference](docs/SCRIPTS-REFERENCE.md)

## 📧 Contact

**Jyothi Prakash Ventrapragada**
- **Email:** prakashvj@gmail.com
- **LinkedIn:** [linkedin.com/in/jyothiprakash](https://linkedin.com/in/jyothiprakash)
- **Location:** India

---

**Built with ❤️ using Azure Static Web Apps and modern deployment automation**
