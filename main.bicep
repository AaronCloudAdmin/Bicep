// main.bicep - Enterprise Orchestrator Template
targetScope = 'resourceGroup'

@description('The Azure region where resources will be deployed.')
param location string = resourceGroup().location

@description('Environment prefix for naming and tagging (e.g., dev, prod).')
param environment string = 'dev'

@description('Project or owner tag for Azure governance.')
param owner string = 'Aaron'

// Enterprise Naming Convention: Ensure global uniqueness using uniqueString()
var uniqueSuffix = uniqueString(resourceGroup().id)
var storageAccountName = 'st${environment}${uniqueSuffix}' // Follows 3-24 char, lowercase alphanumeric rule

// Orchestrating Module 1: Calling the isolated Storage Blueprint
module storageModule 'modules/storage.bicep' = {
  name: 'deployStorageAccountModule'
  params: {
    storageAccountName: storageAccountName
    location: location
    environment: environment
    owner: owner
  }
}

// Exposing outputs from the orchestrator tier
output storageAccountName string = storageAccountName
output storageAccountEndpoint string = storageModule.outputs.storageEndpoint
