// Static Web App Bicep Module
// Reusable module for deploying Azure Static Web Apps
// Supports configuration for resume/portfolio websites

@description('Name of the Static Web App')
param name string

@description('Azure region for deployment')
param location string

@description('GitHub repository URL')
param repositoryUrl string

@description('Repository branch to deploy from')
param repositoryBranch string = 'main'

@description('Static Web App SKU')
@allowed(['Free', 'Standard'])
param skuName string = 'Free'

@description('Resource tags')
param resourceTags object = {}

@description('Path to the app code within the repository')
param buildPath string = '/src'

@description('Path to the build output')
param outputPath string = ''

@description('Path to the API code (if any)')
param apiPath string = ''

@description('Enable staging environments')
param allowStagingEnvironments bool = false

@description('Enable enterprise-grade CDN')
param enableEnterpriseCdn bool = false

// Deploy the Static Web App
resource staticWebApp 'Microsoft.Web/staticSites@2024-04-01' = {
  name: name
  location: location
  tags: resourceTags
  sku: {
    name: skuName
    tier: skuName
  }
  properties: {
    repositoryUrl: repositoryUrl
    branch: repositoryBranch
    stagingEnvironmentPolicy: allowStagingEnvironments ? 'Enabled' : 'Disabled'
    allowConfigFileUpdates: true
    buildProperties: {
      appLocation: buildPath
      outputLocation: outputPath
      apiLocation: apiPath
      skipGithubActionWorkflowGeneration: false
    }
    enterpriseGradeCdnStatus: enableEnterpriseCdn ? 'Enabled' : 'Disabled'
    publicNetworkAccess: 'Enabled'
  }
}

// Configure custom domain if provided (optional for future use)
// This would require additional parameters and DNS configuration

// Outputs
output id string = staticWebApp.id
output name string = staticWebApp.name
output defaultHostname string = 'https://${staticWebApp.properties.defaultHostname}'
// Note: Deployment token will be retrieved separately for security
// output deploymentToken string = staticWebApp.listSecrets().properties.apiKey
output repositoryUrl string = staticWebApp.properties.repositoryUrl
output customDomains array = staticWebApp.properties.customDomains
