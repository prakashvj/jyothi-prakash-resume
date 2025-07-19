# Custom Domain Setup Guide

## 📋 **Overview**
This guide explains how to configure a custom domain for your resume website. A custom domain is **mandatory** for professional deployment.

## 🚨 **Important Notes**

- **Azure Static Web Apps** get auto-generated names that cannot be changed after deployment
- **Custom domain is required** for professional deployment  
- You must own a domain (purchase from providers like GoDaddy, Namecheap, etc.)

## ⚙️ **Configuration Steps**

### **Step 1: Purchase a Domain**
Purchase a domain from any domain registrar:
- **Recommended**: `yourname.com` or `yourfirstname-lastname.com`
- **Alternative**: `resume.yourname.com` or `portfolio.yourname.com`

### **Step 2: Update Configuration**
Edit `config/environments.json` in the `prod` environment:

```json
{
  "environments": {
    "prod": {
      "azure": {
        "customDomain": {
          "enabled": true,
          "required": true,
          "friendlyName": "yourname",
          "domainType": "external",
          "fullDomain": "yourname.com",
          "autoConfigureDNS": false,
          "description": "Custom domain for the resume website. This is mandatory for professional deployment."
        }
      }
    }
  }
}
```

### **Step 3: Deploy Infrastructure**
Run the deployment:
```bash
git add .
git commit -m "configure custom domain"
git push origin main
```

### **Step 4: Configure DNS**
After deployment, the workflow will provide DNS instructions:
1. Go to your domain registrar's DNS management
2. Add a **CNAME record**:
   - **Name**: `@` (or `www` for www.yourname.com)
   - **Value**: The auto-generated Azure Static Web App hostname
   - **Example**: `purple-ocean-12345.azurestaticapps.net`

## 🔧 **Configuration Examples**

### **Example 1: Root Domain**
```json
"customDomain": {
  "enabled": true,
  "required": true,
  "fullDomain": "jyothiventrapragada.com",
  "domainType": "external"
}
```

### **Example 2: Subdomain**
```json
"customDomain": {
  "enabled": true,
  "required": true, 
  "fullDomain": "resume.jyothiventrapragada.com",
  "domainType": "external"
}
```

## ✅ **Validation Rules**

The workflow validates:
- ✅ Domain format: `yourname.com` or `subdomain.yourname.com`
- ✅ Required field: Must be configured before deployment
- ✅ Valid characters: alphanumeric and hyphens only

## 🚨 **Common Issues**

### **Issue**: "Custom domain is required but not configured"
**Solution**: Update `environments.json` with your domain

### **Issue**: "Invalid domain format"
**Solution**: Use format like `yourname.com` (no http://, no paths)

### **Issue**: Domain not resolving
**Solution**: Wait 24-48 hours for DNS propagation

## 💡 **Best Practices**

1. **Use professional domain**: `yourname.com` looks more professional than auto-generated URLs
2. **Keep it simple**: Avoid complex subdomains
3. **SSL automatic**: Azure provides free SSL certificates for custom domains
4. **Monitor**: Check domain status in Azure Portal after configuration

## 🔗 **Resources**

- [Azure Static Web Apps Custom Domains](https://docs.microsoft.com/azure/static-web-apps/custom-domain)
- [Domain Registrars](https://www.namecheap.com/) | [GoDaddy](https://www.godaddy.com/)
- [DNS Propagation Checker](https://www.whatsmydns.net/)
