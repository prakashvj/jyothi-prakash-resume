// Main Bicep template for Jyothi Prakash Resume Website
// Deploys Azure Static Web App with zero-cost (Free) tier
targetScope = 'resourceGroup'

@minLength(1)
@maxLength(64)
@description('Name prefix for all resources (alphanumeric only)')
param environmentName string

@minLength(1)
@description('Primary location for all resources')
param location string

@description('Static Web App name - fixed to avoid duplicates')
param staticWebAppName string = 'jyothi-resume-WebApp'

@description('Tags to apply to all resources')
param tags object = {
  'azd-env-name': environmentName
  project: 'jyothi-resume-website'
  environment: 'production'
  'cost-center': 'personal'
  owner: 'jyothi-prakash'
}

// Static Web App module - using fixed name to prevent duplicates
module staticWebApp 'core/host/staticwebapp.bicep' = {
  name: 'staticwebapp'
  params: {
    name: staticWebAppName  // Use fixed name instead of generated one
    location: location
    tags: union(tags, { 'azd-service-name': 'web' })
  }
}

// Outputs for azd integration
output AZURE_LOCATION string = location
output AZURE_TENANT_ID string = tenant().tenantId
output AZURE_SUBSCRIPTION_ID string = subscription().subscriptionId
output AZURE_RESOURCE_GROUP string = resourceGroup().name
output RESOURCE_GROUP_ID string = resourceGroup().id

// Static Web App outputs
output STATIC_WEB_APP_NAME string = staticWebApp.outputs.name
output STATIC_WEB_APP_HOSTNAME string = staticWebApp.outputs.hostname
output STATIC_WEB_APP_URL string = staticWebApp.outputs.uri
output STATIC_WEB_APP_RESOURCE_ID string = staticWebApp.outputs.resourceId
