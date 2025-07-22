# 🏠 Jyothi Prakash Resume Website

Professional resume website for **Jyothi Prakash Ventrapragada**, Senior Site Reliability Engineering Manager, showcasing 25+ years of technology experience with Azure cloud environments, database architecture, and large-scale distributed systems.

## 🌐 Live Website

**Production URL:** https://orange-wave-01f74d300.1.azurestaticapps.net

## 🚀 Quick Start (5 minutes)

### 1. Fork and Clone
```bash
# Fork this repository on GitHub first, then clone your fork
git clone https://github.com/your-username/jyothi-prakash-resume.git
cd jyothi-prakash-resume
```

### 2. Configure Azure Authentication (Optional for OIDC)
If you want to use OIDC authentication, edit `config/environments.json`:
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

### 3. Deploy to Azure
```bash
# Push to main branch triggers automatic GitHub Actions deployment
git add .
git commit -m "Initial setup: Configure Azure authentication"
git push origin main
```

**✅ That's it! GitHub Actions will automatically deploy your website to Azure!**

👉 **New to the project? Start with [Quick Start Guide](docs/QUICK-START.md)** 👈

## 🏗️ Architecture

- **Frontend:** Static HTML with modern CSS and JavaScript
- **Hosting:** Azure Static Web Apps (Free Tier)
- **CI/CD:** GitHub Actions with automated deployment
- **Infrastructure:** Bicep (Infrastructure as Code)
- **Configuration:** Centralized `environments.json` system
- **Authentication:** OIDC or Interactive Azure CLI

## 📋 Key Features

- ✅ **Print-Optimized:** Fits exactly 3 pages when printed
- ✅ **Responsive Design:** Mobile-friendly professional layout
- ✅ **Fast Loading:** Single HTML file with embedded assets
- ✅ **GitHub Actions CI/CD:** Automatic deployment on push
- ✅ **Multi-Environment:** Support for prod, staging, dev environments
- ✅ **Smart Deployment:** Only deploys when content actually changes
- ✅ **Configuration Management:** Centralized settings system
- ✅ **Comprehensive Validation:** Pre and post-deployment checks

## 📚 Documentation

| Document | Description | Use Case |
|----------|-------------|----------|
| [🚀 Quick Start](docs/QUICK-START.md) | Get started in 5 minutes | First-time setup |
| [⚙️ Configuration System](docs/CONFIGURATION-SYSTEM.md) | Environment and configuration management | Understanding the config system |
| [🔄 Clean Execution Flowchart](docs/CLEAN-EXECUTION-FLOWCHART.md) | Complete GitHub Actions workflow visualization | Understanding the CI/CD pipeline |
| [📊 Complete Execution Flow](docs/COMPLETE-EXECUTION-FLOW.md) | Detailed pipeline documentation | Advanced deployment scenarios |
| [🔧 Troubleshooting](docs/TROUBLESHOOTING.md) | Common issues and solutions | Problem resolution |

## ⚡ How It Works

```bash
# 🚀 Make changes to your resume
git add src/index.html
git commit -m "Update: Add new project experience"

# 📤 Push triggers automatic deployment
git push origin main

# 🤖 GitHub Actions automatically:
# 1. Validates configuration
# 2. Authenticates with Azure (OIDC or Interactive)
# 3. Checks existing resources (smart skipping)
# 4. Deploys only if changes detected
# 5. Provides live URL

# ✅ Your website is live!
```

## 🎯 Common Workflows

### First-Time Setup
```bash
# 1. Fork and clone the repository
git clone https://github.com/your-username/jyothi-prakash-resume.git

# 2. Customize your resume content
# Edit src/index.html with your details

# 3. Push to deploy
git add .
git commit -m "Initial: Set up my resume website"
git push origin main
```

### Regular Updates
```bash
# Create feature branch for changes
git checkout -b feature/update-resume-content

# Make your changes to src/index.html or src/css/style.css
# Edit your resume content

# Commit and push
git add .
git commit -m "Update: Add new project experience"
git push origin feature/update-resume-content

# Create Pull Request on GitHub
# After review and approval, merge triggers automatic deployment
```

### Monitoring Your Deployment
1. **Push to main** triggers GitHub Actions
2. **Check Actions tab** on GitHub for deployment status
3. **View live website** at the URL provided in Actions output
4. **Review logs** in GitHub Actions for any issues

## 🔧 Configuration System

This project uses **GitHub Actions** with a centralized configuration system supporting multiple environments:

### Configuration Files
- `config/environments.json` - Environment-specific settings
- `.github/workflows/full-infrastructure-deploy.yml` - GitHub Actions workflow
- `infra/main.bicep` - Azure infrastructure template

### Multi-Environment Support
```json
{
  "environments": {
    "prod": {
      "azure": {
        "resourceGroup": "jyothi-resume-RG",
        "staticWebAppName": "jyothiventrapragada-resume",
        "location": "eastasia",
        "auth": {
          "clientId": "your-client-id",
          "tenantId": "your-tenant-id",
          "subscriptionId": "your-subscription-id"
        }
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
│   ├── index.html                   # Main resume website
│   ├── css/style.css               # Styling
│   └── js/main.js                  # JavaScript functionality
├── 📁 .github/workflows/            # GitHub Actions CI/CD
│   └── full-infrastructure-deploy.yml # Main deployment workflow
├── 📁 config/                       # Configuration management
│   └── environments.json            # Environment settings
├── 📁 infra/                        # Infrastructure as Code
│   ├── main.bicep                   # Main Bicep template
│   ├── main.parameters.json         # Deployment parameters
│   └── staticwebapp.bicep           # Static Web App module
├── 📁 docs/                         # Documentation
│   ├── QUICK-START.md               # 5-minute setup guide
│   ├── CONFIGURATION-SYSTEM.md      # Config system guide
│   ├── CLEAN-EXECUTION-FLOWCHART.md # Workflow visualization
│   └── TROUBLESHOOTING.md           # Problem resolution
└── 📁 logs/                         # Deployment logs (local scripts)
```

## 🚀 GitHub Actions Workflow

The deployment is fully automated through GitHub Actions:

| Trigger | Action | Duration |
|---------|---------|----------|
| **Push to main** | Full deployment (if infrastructure missing) | 8-12 minutes |
| **Push to main** | Content-only deployment (if infrastructure exists) | 2-4 minutes |
| **No changes** | Skip deployment (validation only) | 1-2 minutes |
| **PR opened** | Deploy to preview environment | 5-8 minutes |
| **PR closed** | Cleanup preview environment | 1-2 minutes |

## 🌍 Multi-Environment Support

The GitHub Actions workflow automatically detects and deploys to different environments based on configuration:

```json
{
  "environments": {
    "prod": { /* Production settings */ },
    "staging": { /* Staging settings */ },
    "dev": { /* Development settings */ }
  }
}
```

## 💰 Cost & Performance

- **Azure Static Web Apps Free Tier:** $0/month
- **100GB bandwidth included**
- **GitHub Actions:** 2,000 minutes/month free
- **Page Load Speed:** < 2 seconds
- **Lighthouse Score:** 95+ (Performance, Accessibility, SEO)
- **Print Optimization:** Exactly 3 pages when printed

## 🔒 Security Features

- ✅ **HTTPS Only:** Enforced SSL/TLS encryption
- ✅ **Managed Certificates:** Automatic SSL provisioning
- ✅ **No Backend Dependencies:** Reduced attack surface
- ✅ **OIDC Authentication:** Secure GitHub to Azure authentication
- ✅ **Azure Security:** Built-in Azure protection features
- ✅ **No Secrets in Code:** Authentication via GitHub Actions

## 🛠️ Technologies

- **Frontend:** HTML5, CSS3, JavaScript (ES6+)
- **Fonts:** Google Fonts (Playfair Display, Source Sans Pro)
- **Infrastructure:** Azure Bicep
- **CI/CD:** GitHub Actions
- **Deployment:** Azure Static Web Apps
- **Configuration:** JSON-based environment system
- **Authentication:** Azure OIDC or Interactive login

## 🔧 Development

### Local Testing
```bash
# Open website locally
start src/index.html  # Windows
open src/index.html   # macOS
```

### Making Changes
1. **Edit content:** Modify `src/index.html` for resume updates
2. **Test locally:** Open in browser to preview changes
3. **Commit changes:** `git add . && git commit -m "Update: description"`
4. **Deploy automatically:** `git push origin main`
5. **Verify deployment:** Check GitHub Actions tab for status

### Print Layout Testing
```javascript
// Test print layout in browser console
window.print();
```

## 🆘 Need Help?

- 🚀 **New User?** Start with [Quick Start Guide](docs/QUICK-START.md)
- ⚙️ **Configuration Issues?** Check [Configuration System](docs/CONFIGURATION-SYSTEM.md)
- 🔄 **Workflow Questions?** See [Clean Execution Flowchart](docs/CLEAN-EXECUTION-FLOWCHART.md)
- 🔧 **Deployment Problems?** Review [Troubleshooting Guide](docs/TROUBLESHOOTING.md)
- 📊 **Understanding Pipeline?** Check [Complete Execution Flow](docs/COMPLETE-EXECUTION-FLOW.md)

## 📧 Contact

**Jyothi Prakash Ventrapragada**
- **Email:** prakashvj@gmail.com
- **LinkedIn:** [linkedin.com/in/jyothiprakash](https://linkedin.com/in/jyothiprakash)
- **Location:** India

---

**Built with ❤️ using Azure Static Web Apps and GitHub Actions automation**
