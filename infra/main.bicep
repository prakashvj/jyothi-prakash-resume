// Resume Website Template - Infrastructure Parameters
// This configuration file contains all the parameters needed to deploy a resume website
// Template can be reused for any portfolio/resume website by modifying the parameters

targetScope = 'resourceGroup'

// Core parameters 
@description('The name of the website/project')
param siteName string = 'jyothi-prakash-resume'

@description('Azure region for deployment')
param location string = resourceGroup().location

@description('Resource prefix for consistent naming')
param resourcePrefix string = 'jpr'

@description('GitHub repository for source code')
param repositoryUrl string = 'https://github.com/prakashvj/jyothi-prakash-resume'

@description('GitHub repository branch')
param repositoryBranch string = 'main'

@description('Static Web App SKU')
@allowed(['Free', 'Standard'])
param staticWebAppSku string = 'Free'

@description('Tags for all resources')
param resourceTags object = {
  Owner: 'Jyothi Prakash'
  Project: 'Resume Website'
  Environment: 'Production'
  CostCenter: 'Personal'
  Deployment: 'AZD'
}

@description('Path to the app code within the repository')
param buildPath string = '/src'

@description('Path to the build output')
param outputPath string = ''

@description('Path to the API code (if any)')
param apiPath string = ''

// Generate unique resource names using the template pattern
var resourceToken = toLower(uniqueString(subscription().id, resourceGroup().id, location))
var locationShort = 'eas'
var staticWebAppName = '${resourcePrefix}-${siteName}-${locationShort}-${resourceToken}'

// Output the configuration for verification
output deploymentConfig object = {
  siteName: siteName
  staticWebAppName: staticWebAppName
  location: location
  repository: repositoryUrl
  tier: staticWebAppSku
  resourceToken: resourceToken
}

// Deploy the Static Web App
module staticWebApp 'modules/staticwebapp.bicep' = {
  name: 'deploy-${staticWebAppName}'
  params: {
    name: staticWebAppName
    location: location
    repositoryUrl: repositoryUrl
    repositoryBranch: repositoryBranch
    skuName: staticWebAppSku
    resourceTags: resourceTags
    buildPath: buildPath
    outputPath: outputPath
    apiPath: apiPath
  }
}

// Output important information
output staticWebAppUrl string = staticWebApp.outputs.defaultHostname
output staticWebAppName string = staticWebAppName
output resourceGroupName string = resourceGroup().name
