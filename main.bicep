targetScope = 'resourceGroup'

@description('The Azure region where resources will be deployed.')
param location string = resourceGroup().location

@description('Environment prefix for naming and tagging (e.g., dev, prod).')
param environment string = 'dev'

@description('Project or owner tag for Azure governance.')
param owner string = 'Aaron'

@description('Administrator username for the Virtual Machine.')
param adminUsername string = 'azureuser'

@description('Administrator password for the Virtual Machine.')
@secure()
param adminPasswordOrKey string

var uniqueSuffix = uniqueString(resourceGroup().id)
var storageAccountName = 'st${environment}${uniqueSuffix}'
var hubVnetName = 'vnet-hub-${environment}-${location}'
var spokeVnetName = 'vnet-spoke-${environment}-${location}'
var nsgName = 'nsg-spoke-${environment}-${location}'
var vmName = 'vm${environment}01'

// Module 1: Secure Storage Account
module storageModule 'modules/storage.bicep' = {
  name: 'deployStorageAccountModule'
  params: {
    storageAccountName: storageAccountName
    location: location
    environment: environment
    owner: owner
  }
}

// Module 2: Hub Virtual Network
module hubVnetModule 'modules/vnet.bicep' = {
  name: 'deployHubVNetModule'
  params: {
    vnetName: hubVnetName
    location: location
    environment: environment
    owner: owner
  }
}

// Module 3: Spoke Virtual Network
module spokeVnetModule 'modules/spoke-vnet.bicep' = {
  name: 'deploySpokeVNetModule'
  params: {
    vnetName: spokeVnetName
    location: location
    environment: environment
    owner: owner
  }
}

// Module 4: Peering from Hub to Spoke
module hubToSpokePeering 'modules/vnet-peering.bicep' = {
  name: 'deployHubToSpokePeering'
  params: {
    peeringName: 'hub-to-spoke-peering'
    localVnetName: hubVnetModule.outputs.vnetName
    remoteVnetId: spokeVnetModule.outputs.spokeVnetId
  }
}

// Module 5: Peering from Spoke to Hub
module spokeToHubPeering 'modules/vnet-peering.bicep' = {
  name: 'deploySpokeToHubPeering'
  params: {
    peeringName: 'spoke-to-hub-peering'
    localVnetName: spokeVnetModule.outputs.spokeVnetName
    remoteVnetId: hubVnetModule.outputs.vnetId
  }
}

// Module 6: Network Security Group for Spoke Subnet
module nsgModule 'modules/nsg.bicep' = {
  name: 'deployNsgModule'
  params: {
    nsgName: nsgName
    location: location
    environment: environment
    owner: owner
  }
}

// Module 7: Virtual Machine in Spoke Subnet
module vmModule 'modules/vm.bicep' = {
  name: 'deployVmModule'
  params: {
    vmName: vmName
    location: location
    subnetId: spokeVnetModule.outputs.workloadSubnetId
    nsgId: nsgModule.outputs.nsgId
    adminUsername: adminUsername
    adminPasswordOrKey: adminPasswordOrKey
    environment: environment
    owner: owner
  }
}

var privateDnsZoneName = 'internal.holleywood.local'

// Module 8: Private DNS Zone and Links
module privateDnsModule 'modules/private-dns.bicep' = {
  name: 'deployPrivateDnsModule'
  params: {
    zoneName: privateDnsZoneName
    hubVnetId: hubVnetModule.outputs.vnetId
    spokeVnetId: spokeVnetModule.outputs.spokeVnetId
    environment: environment
    owner: owner
  }
}

// Outputs
output storageEndpoint string = storageModule.outputs.storageEndpoint
output hubVnetId string = hubVnetModule.outputs.vnetId
output spokeVnetId string = spokeVnetModule.outputs.spokeVnetId
output vmId string = vmModule.outputs.vmId
output privateDnsZoneId string = privateDnsModule.outputs.zoneId
