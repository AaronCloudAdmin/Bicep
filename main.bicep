targetScope = 'resourceGroup'

@description('The Azure region where resources will be deployed.')
param location string = resourceGroup().location

@description('Environment prefix for naming and tagging (e.g., dev, prod).')
param environment string = 'dev'

@description('Project or owner tag for Azure governance.')
param owner string = 'Aaron'

var uniqueSuffix = uniqueString(resourceGroup().id)
var storageAccountName = 'st${environment}${uniqueSuffix}'
var hubVnetName = 'vnet-hub-${environment}-${location}'
var spokeVnetName = 'vnet-spoke-${environment}-${location}'

module storageModule 'modules/storage.bicep' = {
  name: 'deployStorageAccountModule'
  params: {
    storageAccountName: storageAccountName
    location: location
    environment: environment
    owner: owner
  }
}

module hubVnetModule 'modules/vnet.bicep' = {
  name: 'deployHubVNetModule'
  params: {
    vnetName: hubVnetName
    location: location
    environment: environment
    owner: owner
  }
}

module spokeVnetModule 'modules/spoke-vnet.bicep' = {
  name: 'deploySpokeVNetModule'
  params: {
    vnetName: spokeVnetName
    location: location
    environment: environment
    owner: owner
  }
}

module hubToSpokePeering 'modules/vnet-peering.bicep' = {
  name: 'deployHubToSpokePeering'
  params: {
    peeringName: 'hub-to-spoke-peering'
    localVnetName: hubVnetModule.outputs.vnetName
    remoteVnetId: spokeVnetModule.outputs.spokeVnetId
  }
}

module spokeToHubPeering 'modules/vnet-peering.bicep' = {
  name: 'deploySpokeToHubPeering'
  params: {
    peeringName: 'spoke-to-hub-peering'
    localVnetName: spokeVnetModule.outputs.spokeVnetName
    remoteVnetId: hubVnetModule.outputs.vnetId
  }
}

output storageEndpoint string = storageModule.outputs.storageEndpoint
output hubVnetId string = hubVnetModule.outputs.vnetId
output spokeVnetId string = spokeVnetModule.outputs.spokeVnetId
