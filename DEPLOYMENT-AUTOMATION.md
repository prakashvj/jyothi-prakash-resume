# 🚀 One-Command Deployment Guide

This document explains how to avoid back-and-forth deployment issues and deploy your resume website with a single command.

## 🎯 Quick Solutions

### Option 1: One-Command PowerShell Script (Recommended)
```powershell
# From the repository root directory:
.\scripts\deploy-one-command.ps1
```

### Option 2: Quick Content Updates
```powershell
# When you only changed content (HTML/CSS):
.\scripts\quick-deploy.ps1
```

### Option 3: Automated GitHub Actions (Set and Forget)
Push to main branch → Automatically deploys ✨

---

## 🔧 Setup Instructions

### 1. PowerShell Script Setup
The scripts are already created in `/scripts/` folder:
- `deploy-one-command.ps1` - Full deployment (infrastructure + content)
- `quick-deploy.ps1` - Content-only deployment (faster)

### 2. GitHub Actions Automation Setup

#### Step 1: Add Secret to GitHub
1. Go to your GitHub repository: https://github.com/prakashvj/jyothi-prakash-resume
2. Click **Settings** → **Secrets and variables** → **Actions**
3. Click **New repository secret**
4. Name: `AZURE_STATIC_WEB_APPS_API_TOKEN`
5. Value: `179b8e77b704844f2de673c2e2aa45fb2993f91b8a57834aab45d1fb0801173501-6d042f5e-77a4-4272-bbb6-195d38d8302f00007250502ea200`

#### Step 2: Commit and Push
```bash
git add .
git commit -m "Add automated deployment pipeline"
git push origin main
```

**That's it!** From now on, every push to main branch automatically deploys.

---

## 🛠 How It Fixes the Issues

### Previous Problems:
- ❌ AZD created duplicate resources with random names
- ❌ Multiple manual deployment steps required
- ❌ Inconsistent deployment results
- ❌ Manual token management

### New Solutions:
- ✅ **Fixed resource names** - Always uses `jyothi-resume-WebApp`
- ✅ **Single command** - One script does everything
- ✅ **Automated GitHub Actions** - Push code = Live site
- ✅ **Error handling** - Scripts detect and handle common issues
- ✅ **Idempotent deployments** - Safe to run multiple times

---

## 📋 Deployment Options Explained

### 1. Full Deployment (`deploy-one-command.ps1`)
**When to use:** First time setup or infrastructure changes
**What it does:**
- ✅ Provisions Azure resources (if needed)
- ✅ Deploys website content
- ✅ Configures environment variables
- ✅ Outputs live URL

**Time:** ~2-3 minutes

### 2. Quick Deploy (`quick-deploy.ps1`)
**When to use:** Content changes only (HTML, CSS, JS)
**What it does:**
- ✅ Deploys content directly to existing Static Web App
- ✅ Uses production environment
- ✅ Fast deployment

**Time:** ~30-60 seconds

### 3. GitHub Actions (Automatic)
**When to use:** Set it once, forget it
**What it does:**
- ✅ Triggers on every push to main branch
- ✅ Builds and deploys automatically
- ✅ Works from any device
- ✅ No local setup required

**Time:** ~2-3 minutes (automatic)

---

## 🎯 Recommended Workflow

### Daily Development:
1. Edit your resume content (`src/index.html`, `src/css/style.css`)
2. Test locally: `npx http-server src -p 3000`
3. Deploy: `.\scripts\quick-deploy.ps1`
4. ✨ Live in 30 seconds!

### Major Changes:
1. Make infrastructure or configuration changes
2. Deploy: `.\scripts\deploy-one-command.ps1`
3. ✨ Everything provisioned and deployed!

### Automated Workflow:
1. Edit content
2. `git add . && git commit -m "Update resume" && git push`
3. ✨ GitHub Actions automatically deploys!

---

## 🔗 Your Live Website

**Production URL:** https://mango-water-0502ea200.1.azurestaticapps.net

**Resource Details:**
- **Name:** jyothi-resume-WebApp
- **Resource Group:** jyothi-resume-RG
- **Region:** East Asia
- **Type:** Azure Static Web App (Free Tier)

---

## 🆘 Troubleshooting

### "Deployment token not found"
```powershell
az login
.\scripts\quick-deploy.ps1
```

### "Resource already exists" errors
```powershell
.\scripts\deploy-one-command.ps1 -ForceRedeploy
```

### "AZD permission errors"
```powershell
azd auth login
.\scripts\deploy-one-command.ps1
```

### GitHub Actions not triggering
1. Check if secret `AZURE_STATIC_WEB_APPS_API_TOKEN` is added
2. Verify workflow file is in `.github/workflows/`
3. Check Actions tab for error details

---

## 💡 Pro Tips

1. **Bookmark your live URL** for quick access
2. **Use quick-deploy script** for daily content updates
3. **Set up GitHub Actions** for hands-off deployment
4. **Test locally first** with `npx http-server src -p 3000`
5. **Keep deployment tokens secure** - never commit them to git

---

## 🎉 Success!

You now have three ways to deploy with **one command**:
- ⚡ PowerShell scripts for instant deployment
- 🤖 GitHub Actions for automated deployment  
- 🛡️ Robust error handling and recovery

No more back-and-forth deployment issues! 🚀
