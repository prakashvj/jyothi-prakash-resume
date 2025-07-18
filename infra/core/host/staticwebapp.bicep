// Azure Static Web App with Free tier configuration
// Optimized for zero-cost deployment of static websites

@description('The name of the Static Web App')
param name string

@description('The location for the Static Web App')
param location string

@description('Tags to apply to the Static Web App')
param tags object = {}

@description('Repository URL for GitHub integration (optional)')
param repositoryUrl string = ''

@description('Repository branch for deployment')
param branch string = 'main'

@description('Build properties for the static site')
param buildProperties object = {
  appLocation: '/'
  apiLocation: ''
  outputLocation: '/'
  skipGithubActionWorkflowGeneration: true
}

@description('Allow custom domains')
param allowCustomDomains bool = true

@description('Enable staging environments')
param stagingEnvironmentPolicy string = 'Enabled'

@description('Public network access')
param publicNetworkAccess string = 'Enabled'

// Azure Static Web App resource
resource staticWebApp 'Microsoft.Web/staticSites@2024-04-01' = {
  name: name
  location: location
  tags: union(tags, {
    'service-type': 'static-web-app'
    tier: 'free'
    purpose: 'resume-website'
  })
  
  // Free tier SKU
  sku: {
    name: 'Free'
    tier: 'Free'
  }
  
  properties: {
    // Repository configuration (optional for manual deployment)
    repositoryUrl: !empty(repositoryUrl) ? repositoryUrl : null
    branch: !empty(repositoryUrl) ? branch : null
    
    // Build configuration
    buildProperties: buildProperties
    
    // Security and access configuration
    publicNetworkAccess: publicNetworkAccess
    stagingEnvironmentPolicy: stagingEnvironmentPolicy
    
    // Allow configuration file updates
    allowConfigFileUpdates: allowCustomDomains
    
    // Provider for deployment
    provider: 'Custom'
  }
}

// Outputs for integration with deployment pipelines
output id string = staticWebApp.id
output name string = staticWebApp.name
output hostname string = staticWebApp.properties.defaultHostname
output uri string = 'https://${staticWebApp.properties.defaultHostname}'
output resourceId string = staticWebApp.id
output location string = staticWebApp.location

// Custom domain information (for future use)
output customDomains array = staticWebApp.properties.customDomains
