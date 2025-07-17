// Azure Static Web App resource definition
// Optimized for minimal cost using the free tier with enterprise-grade security

@description('Name of the Static Web App')
param name string

@description('Azure region for deployment')
param location string

@description('GitHub repository URL')
param repositoryUrl string = ''

@description('GitHub branch to deploy from')
param branch string = 'main'

@description('GitHub repository token for CI/CD')
@secure()
param repositoryToken string = ''

@description('Environment name for configuration')
param environmentName string

@description('Resource tags')
param tags object = {}

// Static Web App with free tier and security hardening
resource staticWebApp 'Microsoft.Web/staticSites@2024-04-01' = {
  name: name
  location: location
  tags: tags
  sku: {
    name: 'Free'  // Using free tier to minimize costs
    tier: 'Free'
  }
  properties: {
    // Repository configuration for CI/CD
    repositoryUrl: repositoryUrl
    branch: branch
    repositoryToken: repositoryToken
    
    // Build configuration
    buildProperties: {
      appLocation: '/'           // Root directory for app
      apiLocation: ''            // No API for static resume site
      outputLocation: 'src'      // Output directory
      skipGithubActionWorkflowGeneration: false
    }
    
    // Security and access control
    publicNetworkAccess: 'Enabled'
    stagingEnvironmentPolicy: environmentName == 'prod' ? 'Disabled' : 'Enabled'  // Only prod has staging disabled
    allowConfigFileUpdates: true
    
    // Enterprise features (available in free tier)
    enterpriseGradeCdnStatus: 'Disabled'  // Disable to stay in free tier
  }
}

// Configure security headers and routing via staticwebapp.config.json (handled in app code)
// No additional security resources needed as SWA includes:
// - Automatic HTTPS/TLS
// - DDoS protection via Azure Front Door
// - Built-in authentication (if needed)
// - Global CDN distribution

// Outputs for reference
@description('Static Web App resource ID')
output staticWebAppId string = staticWebApp.id

@description('Static Web App name')
output staticWebAppName string = staticWebApp.name

@description('Default hostname for the static web app')
output defaultHostname string = staticWebApp.properties.defaultHostname

@description('Custom domains (if any)')
output customDomains array = staticWebApp.properties.customDomains

@description('Deployment token for GitHub Actions - retrieve manually for security')
output deploymentTokenNote string = 'Run: az staticwebapp secrets list --name ${staticWebApp.name} --query properties.apiKey -o tsv'

@description('Content distribution endpoint')
output contentDistributionEndpoint string = staticWebApp.properties.contentDistributionEndpoint

@description('Repository URL configured')
output repositoryUrl string = staticWebApp.properties.repositoryUrl

@description('Branch configured')
output branch string = staticWebApp.properties.branch
