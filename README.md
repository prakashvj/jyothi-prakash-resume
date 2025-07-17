# Jyothi Prakash Ventrapragada - Professional Resume Website

A modern, responsive resume website hosted on Azure Static Web Apps, showcasing expertise in Site Reliability Engineering, Azure cloud services, and engineering leadership.

## 🚀 Live Website
- **Production**: Will be available after deployment
- **Pre-Production**: Will be available after deployment

## 🏗️ Architecture
- **Frontend**: Modern HTML5, CSS3, and JavaScript
- **Hosting**: Azure Static Web Apps (Free Tier)
- **Security**: Built-in DDoS protection, automatic HTTPS
- **CDN**: Global content delivery included
- **CI/CD**: GitHub Actions for automated deployment

## 📁 Repository Structure
```
├── README.md                 # Project documentation
├── azure.yaml                # Azure Developer CLI configuration
├── .gitignore                # Git ignore rules
├── infra/                    # Infrastructure as Code (Bicep)
│   ├── main.bicep           # Main infrastructure definition
│   ├── main.parameters.json # Environment parameters
│   └── staticwebapp.bicep   # Static Web App resource
├── src/                      # Website source code
│   ├── index.html           # Main website page
│   ├── css/                 # Stylesheets
│   │   ├── style.css        # Main styles
│   │   └── responsive.css   # Mobile responsiveness
│   ├── js/                  # JavaScript functionality
│   │   └── main.js          # Interactive features
│   ├── assets/              # Images and documents
│   └── staticwebapp.config.json # SWA configuration
├── docs/                     # Documentation
│   ├── deployment-guide.md  # How to deploy
│   ├── security-guide.md    # Security considerations
│   └── maintenance-guide.md # Ongoing maintenance
└── .github/                 # GitHub automation
    └── workflows/           # CI/CD pipelines
        └── azure-static-web-apps.yml
```

## 🛠️ Local Development

### Prerequisites
- Node.js (for Azure Static Web Apps CLI)
- Azure Developer CLI (azd)
- Git

### Setup Instructions
1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd jyothi-prakash-resume
   ```

2. **Install Azure Static Web Apps CLI**
   ```bash
   npm install -g @azure/static-web-apps-cli
   ```

3. **Run locally**
   ```bash
   swa start src
   ```

4. **Open browser**
   Navigate to `http://localhost:4280`

## 🚀 Deployment

### Using Azure Developer CLI (Recommended)
1. **Login to Azure**
   ```bash
   azd auth login
   ```

2. **Initialize the project**
   ```bash
   azd init
   ```

3. **Deploy to Azure**
   ```bash
   azd up
   ```

### Manual Deployment
See [docs/deployment-guide.md](docs/deployment-guide.md) for detailed instructions.

## 🔒 Security Features
- ✅ Automatic HTTPS/TLS encryption
- ✅ DDoS protection via Azure CDN
- ✅ No sensitive information exposed
- ✅ Content Security Policy (CSP) headers
- ✅ Security headers configuration
- ✅ Input validation and sanitization

## 📱 Features
- ✅ Fully responsive design (mobile, tablet, desktop)
- ✅ Professional color scheme
- ✅ Fast loading times with CDN
- ✅ SEO optimized for professional visibility
- ✅ Accessible design (WCAG 2.1 AA compliant)
- ✅ Print-friendly styles
- ✅ Social media integration (LinkedIn)

## 🔧 Configuration

### Environment Variables
- `AZURE_SUBSCRIPTION_ID`: Azure subscription for deployment
- `AZURE_RESOURCE_GROUP`: Resource group name
- `AZURE_LOCATION`: Azure region (default: East US 2)

### Customization
- Update content in `src/index.html`
- Modify styles in `src/css/`
- Add interactive features in `src/js/`

## 📊 Performance
- ✅ Lighthouse Score: 95+ (Performance, Accessibility, Best Practices, SEO)
- ✅ Core Web Vitals optimized
- ✅ Global CDN delivery
- ✅ Minimal resource usage (fits in free tier)

## 🤝 Contributing
This is a personal resume website. For suggestions or improvements, please create an issue.

## 📄 License
© 2025 Jyothi Prakash Ventrapragada. All rights reserved.

## 📞 Contact
- **Email**: prakashvj@gmail.com
- **LinkedIn**: [linkedin.com/in/jyothiventrapragada](https://www.linkedin.com/in/jyothiventrapragada/)

---
*Built with ❤️ using Azure Static Web Apps*
