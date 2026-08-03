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
var vnetName = 'vnet-${environment}-${location}'

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

// Module 2: Virtual Network with Subnets
module vnetModule 'modules/vnet.bicep' = {
  name: 'deployVNetModule'
  params: {
    vnetName: vnetName
    location: location
    environment: environment
    owner: owner
  }
}

// Outputs from the Orchestrator
output storageEndpoint string = storageModule.outputs.storageEndpoint
output vnetId string = vnetModule.outputs.vnetId
