# 🧠 Workflow Logic Reference

## 🎯 **Change Detection & Deployment Decision Engine**

This document provides a comprehensive breakdown of how the GitHub Actions workflow intelligently determines what actions to take based on the types of files changed in your commits.

---

## 📋 **Core Logic Flow**

### **Primary Decision Tree**
```
Git Push/PR → Change Detection → Decision Engine → Action
     │              │                │            │
     │              ▼                ▼            ▼
     └─── Files ──→ Categorize ──→ Logic ──→ Deploy/Skip
```

### **The Four-Stage Process**

1. **🔍 Change Detection** - Analyze what files were modified
2. **📂 File Categorization** - Sort changes into doc, infra, or content
3. **🧠 Logic Engine** - Apply deployment rules
4. **⚡ Action Execution** - Execute the appropriate deployment strategy

---

## 📁 **File Classification System**

### **📚 Documentation Files (Skip Deployment)**
Files that **DO NOT** trigger any Azure deployment:

```bash
# Documentation patterns that skip deployment
├── docs/**/*.md          # All markdown files in docs/
├── README.md             # Root readme file
├── *.md                  # Any markdown file
├── DOCUMENTATION*.md     # Documentation prefixed files
├── LICENSE               # License files
├── .gitignore           # Git ignore files
└── .vscode/             # VS Code settings
```

**Reference**: Lines 334-335 in `.github/workflows/full-infrastructure-deploy.yml`
```yaml
DOC_FILES=$(echo "$CHANGED_FILES" | grep -E '^docs/.*\.md$|^README\.md$|^.*\.md$|^DOCUMENTATION.*\.md$|^LICENSE$|^\.gitignore$|^\.vscode/')
NON_DOC_FILES=$(echo "$CHANGED_FILES" | grep -v -E '^docs/.*\.md$|^README\.md$|^.*\.md$|^DOCUMENTATION.*\.md$|^LICENSE$|^\.gitignore$|^\.vscode/')
```

### **🏗️ Infrastructure Files (Full Deployment)**
Files that trigger complete infrastructure provisioning + content deployment:

```bash
# Infrastructure patterns that trigger full deployment
├── infra/               # Bicep templates and infrastructure
├── config/              # Configuration files
├── azure.yaml           # Azure Developer CLI configuration
├── .github/workflows/   # GitHub Actions workflow files
└── scripts/             # Deployment and utility scripts
```

**Reference**: Lines 326-329 in `.github/workflows/full-infrastructure-deploy.yml`
```yaml
if echo "$file" | grep -qE '^(infra/|config/|azure\.yaml|\.github/workflows/|scripts/)'; then
  echo "🏗️ Infrastructure file detected: $file"
  INFRASTRUCTURE_CHANGED="true"
fi
```

### **📄 Content Files (Content-Only Deployment)**
Files that trigger content-only deployment (when infrastructure exists):

```bash
# Content patterns that trigger content deployment
├── src/                 # Website source files
├── package.json         # Dependencies and build configuration
├── *.html              # HTML files
├── *.css               # Stylesheets
├── *.js                # JavaScript files
└── assets/             # Images, fonts, other assets
```

**Reference**: Lines 320-324 in `.github/workflows/full-infrastructure-deploy.yml`
```yaml
if echo "$file" | grep -qE '^(src/|package\.json|.*\.html$|.*\.css$|.*\.js$)'; then
  echo "📄 Content file detected: $file"
  CONTENT_CHANGED="true"
fi
```

---

## 🔄 **Deployment Decision Matrix**

### **Scenario 1: Documentation-Only Changes**
```
Input:  📚 Only .md, LICENSE, .gitignore files changed
Logic:  if [ -z "$NON_DOC_FILES" ] && [ -n "$DOC_FILES" ]
Action: ⏭️ SKIP ALL DEPLOYMENT
Result: ✅ Workflow completes without Azure operations
Cost:   💰 $0.00 (No Azure resources touched)
Time:   ⚡ ~30 seconds (Git operations only)
```

**Example Files**: `docs/README.md`, `TROUBLESHOOTING.md`, `LICENSE`

**Reference**: Lines 337-343 in `.github/workflows/full-infrastructure-deploy.yml`

### **Scenario 2: Infrastructure Changes**
```
Input:  🏗️ Bicep, config, or workflow files changed
Logic:  INFRASTRUCTURE_CHANGED="true"
Action: 🚀 FULL INFRASTRUCTURE + CONTENT DEPLOYMENT
Result: ✅ Complete Azure resource provisioning + site update
Cost:   💰 Standard Azure operations
Time:   ⏳ 8-12 minutes (Full deployment cycle)
```

**Example Files**: `infra/main.bicep`, `config/environments.json`, `azure.yaml`

**Reference**: Lines 366-417 in `.github/workflows/full-infrastructure-deploy.yml`

### **Scenario 3: Content-Only Changes**
```
Input:  📄 Website source files changed, no infrastructure
Logic:  CONTENT_CHANGED="true" && resources exist
Action: 📦 CONTENT-ONLY DEPLOYMENT
Result: ✅ Website updated using existing infrastructure
Cost:   💰 Minimal (Content deployment only)
Time:   ⚡ 2-4 minutes (Fast content update)
```

**Example Files**: `src/index.html`, `src/css/style.css`, `package.json`

**Reference**: Lines 418-427 in `.github/workflows/full-infrastructure-deploy.yml`

### **Scenario 4: Mixed Changes (Content + Documentation)**
```
Input:  📄 Website files + 📚 Documentation files
Logic:  NON_DOC_FILES contains content changes
Action: 📦 CONTENT-ONLY DEPLOYMENT
Result: ✅ Website updated, documentation changes ignored for deployment
Cost:   💰 Minimal (Content deployment only)
Time:   ⚡ 2-4 minutes (Documentation doesn't affect deployment)
```

**Example Files**: `src/index.html` + `docs/README.md`

---

## 🧠 **Advanced Logic Conditions**

### **Resource Existence Checking**
The workflow checks if Azure resources already exist before making deployment decisions:

```yaml
# Resource checking logic
├── Resource Group exists? → Skip provisioning
├── Static Web App exists? → Use existing for content deployment
└── Resources missing? → Full infrastructure deployment
```

**Reference**: Lines 219-286 in `.github/workflows/full-infrastructure-deploy.yml`

### **Authentication Fallback Strategy**
```yaml
# Authentication priority
├── 1st: OIDC (OpenID Connect) - Preferred
├── 2nd: Service Principal - Backup
└── 3rd: Interactive Login - Manual fallback
```

**Reference**: Lines 133-218 in `.github/workflows/full-infrastructure-deploy.yml`

### **Deployment Skip Conditions**
The workflow will skip deployment when:

1. **Documentation-only changes**: `skip_deployment=true`
2. **No changes detected**: No relevant files modified
3. **Resource check failures**: Cannot verify Azure resources
4. **Authentication failures**: Cannot connect to Azure

---

## 🔧 **Implementation Details**

### **Change Detection Script Location**
```
File: .github/workflows/full-infrastructure-deploy.yml
Lines: 307-354 (Analyze Content Changes step)
```

### **Key Variables Set**
```bash
# Output variables that control workflow behavior
├── skip_deployment       # true/false - Skip all deployment
├── content_changed       # true/false - Content files modified
├── infrastructure_changed # true/false - Infrastructure files modified
└── resource_changed      # true/false - Azure resources need updates
```

### **Conditional Job Execution**
All subsequent deployment jobs use these conditions:
```yaml
# Skip deployment check
if: steps.content_changes.outputs.skip_deployment != 'true'

# Infrastructure deployment condition
if: (steps.check_resources.outputs.skip_provisioning != 'true' || 
     steps.check_resources.outputs.resource_changed == 'true') && 
     steps.content_changes.outputs.skip_deployment != 'true'

# Content-only deployment condition  
if: steps.check_resources.outputs.skip_provisioning == 'true' && 
    steps.check_resources.outputs.resource_changed != 'true' && 
    steps.content_changes.outputs.content_changed == 'true' && 
    steps.content_changes.outputs.skip_deployment != 'true'
```

---

## 📊 **Performance & Cost Impact**

### **Optimization Results**
- **📚 Documentation changes**: 100% deployment skip → $0 cost
- **📄 Content-only changes**: 70% faster deployment → Reduced costs  
- **🏗️ Infrastructure changes**: Full deployment when needed → Controlled costs
- **🔍 Smart detection**: Prevents unnecessary Azure operations → Cost efficient

### **Workflow Execution Times**
| Change Type | Deployment Action | Estimated Time | Azure Cost Impact |
|-------------|------------------|----------------|-------------------|
| 📚 Documentation | Skip | ~30 seconds | $0.00 |
| 📄 Content Only | Content Deploy | 2-4 minutes | Minimal |
| 🏗️ Infrastructure | Full Deploy | 8-12 minutes | Standard |
| 🚫 No Changes | Skip | ~30 seconds | $0.00 |

---

## 🔍 **Debugging & Troubleshooting**

### **Checking Change Detection**
To debug what the workflow detected:

1. **View Workflow Logs** - Check "Analyze Content Changes" step
2. **Look for Detection Messages**:
   ```
   📄 Content file detected: src/index.html
   🏗️ Infrastructure file detected: infra/main.bicep
   📚 Documentation-only changes detected
   ```

3. **Check Output Variables**:
   ```
   content_changed=true
   infrastructure_changed=false
   skip_deployment=false
   ```

### **Common Issues**
- **Unexpected deployment**: Check if non-doc files were included in commit
- **Deployment skipped**: Verify that actual content/infra files were modified
- **Full deployment triggered**: Infrastructure files might have been changed unintentionally

---

## 📖 **Related Documentation**

- **[🚀 Quick Start Guide](QUICK-START.md)** - Basic setup and first deployment
- **[⚙️ Configuration System](CONFIGURATION-SYSTEM.md)** - Understanding config files
- **[🧠 Intelligent Deployment](INTELLIGENT-DEPLOYMENT.md)** - Resource detection details
- **[🔧 Troubleshooting](TROUBLESHOOTING.md)** - Common problems and solutions
- **[📊 Complete Execution Flow](COMPLETE-EXECUTION-FLOW.md)** - Full workflow documentation

---

## 🎯 **Quick Reference Card**

```
📚 .md files         → SKIP deployment
🏗️ infra/ files      → FULL deployment  
📄 src/ files        → CONTENT deployment
🔀 Mixed changes     → CONTENT deployment (docs ignored)
🚫 No changes        → SKIP deployment
```

**File**: `.github/workflows/full-infrastructure-deploy.yml` | **Lines**: 307-354, 366-427
