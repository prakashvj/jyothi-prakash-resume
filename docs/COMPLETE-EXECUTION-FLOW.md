# Complete Execution Flow Diagram: Azure Static Web Apps CI/CD Pipeline

## 🎯 **Pipeline Overview**

```mermaid
flowchart TD
    Start([🚀 GitHub Event Triggered]) --> EventType{Event Type?}
    
    EventType -->|workflow_dispatch| Manual[👤 Manual Trigger]
    EventType -->|push to main| Push[📤 Push Event]
    EventType -->|pull_request| PR[🔄 Pull Request]
    EventType -->|PR closed| Close[❌ PR Closed]
    
    Manual --> MainJob[🏗️ Full Infrastructure Deploy Job]
    Push --> MainJob
    PR --> MainJob
    Close --> CloseJob[🧹 Close Pull Request Job]
    
    MainJob --> Checkout[📂 Checkout Code]
    CloseJob --> CleanupPR[🧹 Cleanup Preview Environment]
    
    style Start fill:#e1f5fe
    style MainJob fill:#f3e5f5
    style CloseJob fill:#ffebee
    style EventType fill:#fff3e0
```

## 🔄 **Main Execution Pipeline**

```mermaid
flowchart TD
    A[📂 Checkout Code] --> B[🔧 Setup Azure Developer CLI]
    B --> C[📋 Read & Validate Configuration]
    
    C --> D{Configuration Valid?}
    D -->|❌ No| D1[💥 Exit with Error]
    D -->|✅ Yes| E{OIDC Config Available?}
    
    E -->|✅ Yes| F[🔐 Azure Login - OIDC]
    E -->|❌ No| G[🔐 Azure Login - Interactive]
    
    F --> H[⚙️ Azure CLI Setup]
    G --> H
    
    H --> I[🔍 Check Existing Azure Resources]
    
    I --> J{Resource Group Exists?}
    J -->|❌ No| K[🏗️ Full Provisioning Required]
    J -->|✅ Yes| L{Static Web App Exists?}
    
    L -->|❌ No| K
    L -->|✅ Yes| M{Configuration Drift?}
    
    M -->|⚠️ Yes| N[🔄 Update Required]
    M -->|✅ No| O[⏭️ Skip Provisioning]
    
    K --> P[🏗️ Deploy Azure Resources]
    N --> P
    O --> Q[🔑 Get Existing API Token]
    
    P --> P1[📦 Create Resource Group]
    P1 --> P2[🚀 Deploy Bicep Template]
    P2 --> P3[✅ Infrastructure Ready]
    P3 --> R[🔑 Get New API Token]
    
    Q --> S[🔍 Detect Content Changes]
    R --> S
    
    style D1 fill:#ffebee
    style K fill:#fff3e0
    style N fill:#fff8e1
    style O fill:#e8f5e8
    style P3 fill:#e8f5e8
```

## 📦 **Content Deployment Flow**

```mermaid
flowchart TD
    A[🔍 Detect Content Changes] --> B[📂 Git Diff Analysis]
    
    B --> C{Files Changed?}
    C -->|❌ No Changes| D[ℹ️ First Commit/Manual Trigger]
    C -->|✅ Changes Found| E[📝 Analyze Change Types]
    
    D --> F[📦 Default: Deploy Content]
    E --> G{Content Files Changed?}
    
    G -->|src/* or config/*| H[✅ Content Changed = true]
    G -->|Only infra/workflow| I[❌ Content Changed = false]
    
    H --> J{Infrastructure Source?}
    I --> K[⏭️ Skip Content Deployment]
    F --> J
    
    J -->|🆕 New/Updated Infra| L[🔑 Use New API Token]
    J -->|📦 Existing Infra| M[🔑 Use Existing API Token]
    
    L --> N[📤 Deploy Content - New Infrastructure]
    M --> O[📤 Deploy Content - Existing Infrastructure]
    
    N --> P[🌐 Static Web Apps Action]
    O --> P
    
    P --> Q[📂 Upload /src Directory]
    Q --> R[🔨 Process Build Configuration]
    R --> S[🚀 Deploy to Production]
    S --> T[✅ Content Deployment Complete]
    
    K --> U[📋 Log Skip Reason]
    T --> V[🌐 Custom Domain Configuration]
    U --> V
    
    style K fill:#e8f5e8
    style T fill:#e8f5e8
    style U fill:#fff8e1
```

## 🌐 **Custom Domain Configuration Flow**

```mermaid
flowchart TD
    A[🌐 Custom Domain Configuration] --> B{Domain Enabled in Config?}
    
    B -->|❌ No| C[⏭️ Skip Domain Configuration]
    B -->|✅ Yes| D[🔍 Validate Static Web App Exists]
    
    D --> E{Static Web App Found?}
    E -->|❌ No| F[⚠️ Domain Config After Infrastructure]
    E -->|✅ Yes| G{Domain Already Exists?}
    
    G -->|✅ Yes| H[✅ Domain Already Configured]
    G -->|❌ No| I[🌐 Analyze Domain Type]
    
    I --> J{Domain Type?}
    J -->|subdomain.domain.com| K[📝 Subdomain - CNAME Setup]
    J -->|domain.com| L[📝 Apex Domain - TXT + A Setup]
    
    K --> M[🔧 Configure CNAME Validation]
    L --> N[🔧 Configure DNS TXT Validation]
    
    M --> O[📋 Get DNS Configuration Details]
    N --> O
    
    O --> P[🔍 Retrieve Default Hostname]
    P --> Q[🎫 Get Validation Token]
    Q --> R[🌐 Get IP Address]
    R --> S[📝 Generate DNS Instructions]
    
    S --> T{Domain Type Check}
    T -->|CNAME| U[📋 Output CNAME Record Instructions]
    T -->|TXT+A| V[📋 Output TXT + A Record Instructions]
    
    U --> W[✅ DNS Instructions Ready]
    V --> W
    
    C --> X[📋 Log Skip Reason]
    F --> X
    H --> X
    W --> X
    
    style C fill:#e8f5e8
    style F fill:#fff8e1
    style H fill:#e8f5e8
    style W fill:#e8f5e8
    style X fill:#f5f5f5
```

## 📊 **Final Output & Summary Flow**

```mermaid
flowchart TD
    A[📊 Output Deployment Information] --> B{Deployment Type?}
    
    B -->|⏭️ Content Only| C[📋 Content-Only Summary]
    B -->|🏗️ Full Infrastructure| D[📋 Full Infrastructure Summary]
    
    C --> E[📝 Generate Content Update Report]
    D --> F[📝 Generate Infrastructure Report]
    
    E --> G[🌐 Access URL Information]
    F --> G
    
    G --> H{Custom Domain Enabled?}
    H -->|❌ No| I[🔗 Show Default Azure URL]
    H -->|✅ Yes| J[📋 Show Custom Domain + DNS Instructions]
    
    I --> K[✅ Deployment Complete]
    J --> L{Domain Type?}
    
    L -->|CNAME| M[📝 Show CNAME Instructions]
    L -->|TXT+A| N[📝 Show TXT + A Instructions]
    
    M --> O[⏰ Show DNS Propagation Timeline]
    N --> O
    
    O --> P[🔍 Show Verification Commands]
    P --> K
    
    K --> Q[🎉 Pipeline Success]
    
    style K fill:#e8f5e8
    style Q fill:#e8f5e8
```

## 🔀 **Decision Matrix & Conditional Logic**

### **Authentication Decision Tree**
```mermaid
flowchart LR
    A[🔐 Authentication Check] --> B{OIDC Config in environments.json?}
    B -->|✅ clientId, tenantId, subscriptionId| C[🎯 OIDC Federated Identity]
    B -->|❌ Missing/Empty Values| D[👤 Interactive Azure CLI Login]
    
    C --> E[🚀 Automatic Authentication]
    D --> F[📱 Device Code Authentication]
    
    style C fill:#e8f5e8
    style D fill:#fff8e1
```

### **Infrastructure Decision Matrix**
```mermaid
flowchart TD
    A[🔍 Infrastructure Check] --> B{Resource Group?}
    B -->|❌ Not Found| C[🏗️ Full Provisioning]
    B -->|✅ Found| D{Static Web App?}
    
    D -->|❌ Not Found| C
    D -->|✅ Found| E{Configuration Drift?}
    
    E -->|⚠️ Location Changed| F[🔄 Update Resources]
    E -->|✅ Matches Config| G[⏭️ Skip Infrastructure]
    
    C --> H[📦 Deploy Everything]
    F --> H
    G --> I[🔑 Retrieve Existing Token]
    
    style C fill:#fff3e0
    style F fill:#fff8e1
    style G fill:#e8f5e8
```

### **Content Deployment Decision Logic**
```mermaid
flowchart LR
    A[📂 Change Detection] --> B{Git Diff Analysis}
    B -->|src/* changed| C[📦 Deploy Content]
    B -->|config/* changed| C
    B -->|Only infra/* changed| D[⏭️ Skip Content]
    B -->|Only .github/* changed| D
    B -->|No changes detected| E[📱 Manual Trigger - Deploy]
    
    C --> F{Infrastructure State?}
    F -->|🆕 New| G[🔑 New Token]
    F -->|📦 Existing| H[🔑 Existing Token]
    
    style C fill:#e3f2fd
    style D fill:#fff8e1
    style E fill:#e8f5e8
```

## ⚡ **Performance & Optimization Points**

### **Smart Skipping Logic**
```mermaid
flowchart TD
    A[⚡ Performance Optimizations] --> B[🔍 Resource Detection]
    A --> C[📂 Change Detection]
    A --> D[🎯 Conditional Execution]
    
    B --> B1[Skip if RG + SWA exist & no drift]
    C --> C1[Skip content if no src/ changes]
    D --> D1[Skip domain if disabled]
    
    B1 --> E[⏱️ ~2-3 minutes saved]
    C1 --> E
    D1 --> E
    
    style E fill:#e8f5e8
```

### **Parallel Processing**
```mermaid
flowchart LR
    A[🔄 Parallel Operations] --> B[🔐 Authentication]
    A --> C[📋 Config Validation]
    A --> D[🔍 Resource Checks]
    
    B --> E[⏱️ Concurrent Execution]
    C --> E
    D --> E
    
    style E fill:#e8f5e8
```

## 🎯 **Complete Execution Timeline**

| Phase | Duration | Key Operations | Decision Points |
|-------|----------|----------------|-----------------|
| **🚀 Trigger & Setup** | 30-60s | Checkout, AZD setup, config validation | Event type, OIDC availability |
| **🔐 Authentication** | 15-30s | OIDC or interactive login | Config completeness |
| **🔍 Resource Discovery** | 15-45s | Check RG, SWA, configuration drift | Resource existence, drift detection |
| **🏗️ Infrastructure** | 0-300s | Create RG, deploy Bicep template | Skip if exists, deploy if missing |
| **📦 Content Deployment** | 30-120s | Static Web Apps action, file upload | Change detection, token retrieval |
| **🌐 Domain Configuration** | 30-60s | DNS setup, validation instructions | Domain enabled, type detection |
| **📊 Output & Summary** | 10-20s | Generate reports, URLs, instructions | Deployment type, domain status |

## 🎉 **Success Scenarios**

### **Scenario 1: First Deployment**
```
🚀 Manual Trigger → 🔐 OIDC Auth → 🏗️ Create Everything → 📦 Deploy Content → 🌐 Setup Domain → ✅ Success
Timeline: ~8-12 minutes
```

### **Scenario 2: Content Update**
```
📤 Push Event → 🔐 OIDC Auth → ⏭️ Skip Infrastructure → 📦 Deploy Content → ⏭️ Skip Domain → ✅ Success
Timeline: ~2-4 minutes
```

### **Scenario 3: No Changes**
```
📤 Push Event → 🔐 OIDC Auth → ⏭️ Skip Infrastructure → ⏭️ Skip Content → ⏭️ Skip Domain → ✅ Success
Timeline: ~1-2 minutes
```

This comprehensive flow shows exactly how your 500+ line enterprise-grade pipeline executes from trigger to completion! 🎯
