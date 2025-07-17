// Main infrastructure template for Jyothi Prakash Resume Website
// This template creates Azure Static Web Apps for hosting the resume website
// with cost-optimized configuration using the free tier

@description('Name prefix for all resources')
param projectName string = 'jyothi-prakash-resume'

@description('Primary Azure region for deployment')
param location string = resourceGroup().location

@description('Environment name (ppe, prod)')
param environmentName string = 'prod'

@description('GitHub repository URL for the static web app')
param repositoryUrl string = ''

@description('GitHub branch to deploy from')
param branch string = 'main'

@description('GitHub repository token for CI/CD setup')
@secure()
param repositoryToken string = ''

@description('Resource tags for cost tracking and management')
param tags object = {
  Project: projectName
  Environment: environmentName
  Owner: 'Jyothi Prakash Ventrapragada'
  Purpose: 'Resume Website'
  CostCenter: 'Personal'
  CreatedBy: 'AZD'
}

// Generate unique resource names with environment suffix
var resourceNames = {
  staticWebApp: '${projectName}-${environmentName}'
  resourceGroup: resourceGroup().name
}

// Deploy the Static Web App
module staticWebApp 'staticwebapp.bicep' = {
  name: 'staticWebAppDeployment'
  params: {
    name: resourceNames.staticWebApp
    location: location
    repositoryUrl: repositoryUrl
    branch: branch
    repositoryToken: repositoryToken
    tags: tags
    environmentName: environmentName
  }
}

// Outputs for reference and automation
@description('Static Web App resource ID')
output staticWebAppId string = staticWebApp.outputs.staticWebAppId

@description('Static Web App default hostname')
output defaultHostname string = staticWebApp.outputs.defaultHostname

@description('Command to get deployment token for GitHub Actions')
output deploymentTokenCommand string = staticWebApp.outputs.deploymentTokenNote

@description('Resource group name')
output resourceGroupName string = resourceGroup().name

@description('Environment name')
output environment string = environmentName

@description('All resource names created')
output resourceNames object = resourceNames

@description('Website URL')
output websiteUrl string = 'https://${staticWebApp.outputs.defaultHostname}'
