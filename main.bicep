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

// Module 2: Network Security Group (Baseline for workloads)
module nsgModule 'modules/nsg.bicep' = {
  name: 'deployNsgModule'
  params: {
    nsgName: nsgName
    location: location
    environmentName: environment
    owner: owner
  }
}

// Module 3: Hub Virtual Network (excluding Gateway and Bastion subnets from workload NSG)
module hubVnetModule 'modules/vnet.bicep' = {
  name: 'deployHubVNetModule'
  params: {
    vnetName: hubVnetName
    location: location
    environmentName: environment
    owner: owner
    nsgId: nsgModule.outputs.nsgId
  }
}

// Module 4: Spoke Virtual Network (Hosting the Workload Subnet)
module spokeVnetModule 'modules/spoke-vnet.bicep' = {
  name: 'deploySpokeVNetModule'
  params: {
    vnetName: spokeVnetName
    location: location
    environmentName: environment
    owner: owner
    nsgId: nsgModule.outputs.nsgId
  }
}

// Module 5: Peering from Hub to Spoke
module hubToSpokePeering 'modules/vnet-peering.bicep' = {
  name: 'deployHubToSpokePeering'
  params: {
    peeringName: 'hub-to-spoke-peering'
    localVnetName: hubVnetModule.outputs.vnetName
    remoteVnetId: spokeVnetModule.outputs.spokeVnetId
  }
}

// Module 6: Peering from Spoke to Hub
module spokeToHubPeering 'modules/vnet-peering.bicep' = {
  name: 'deploySpokeToHubPeering'
  params: {
    peeringName: 'spoke-to-hub-peering'
    localVnetName: spokeVnetModule.outputs.spokeVnetName
    remoteVnetId: hubVnetModule.outputs.vnetId
  }
}

// Module 7: Standard Layer 4 Load Balancer (Scoped to the Spoke Workload Tier)
module loadBalancerModule './modules/load-balancer.bicep' = {
  name: 'deploySpokeLoadBalancer'
  params: {
    location: location
    lbName: 'lb-${environment}-spoke-workload'
    environment: environment
    owner: owner
  }
}

// Module 8: Virtual Machine in Spoke Subnet
module vmModule 'modules/vm.bicep' = {
  name: 'deployVmModule'
  params: {
    vmName: vmName
    location: location
    subnetId: spokeVnetModule.outputs.workloadSubnetId
    nsgId: nsgModule.outputs.nsgId
    adminUsername: adminUsername
    adminPasswordOrKey: adminPasswordOrKey
    environmentName: environment
    owner: owner
  }
}

var privateDnsZoneName = 'internal.holleywood.local'

// Module 9: Private DNS Zone and Links
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

// Module 10: Private Endpoint Module for Storage Blob
module storagePrivateEndpoint './modules/private-endpoint.bicep' = {
  name: 'deployStoragePrivateEndpoint'
  params: {
    location: location
    storageAccountId: storageModule.outputs.storageAccountId
    storageAccountName: storageModule.outputs.storageAccountName
    subnetId: spokeVnetModule.outputs.workloadSubnetId
    vnetId: spokeVnetModule.outputs.spokeVnetId
    environmentName: environment
    owner: owner
  }
}

// Outputs
output storageAccountName string = storageModule.outputs.storageAccountName
output storageAccountId string = storageModule.outputs.storageAccountId
output storageEndpoint string = storageModule.outputs.storageEndpoint
output hubVnetId string = hubVnetModule.outputs.vnetId
output spokeVnetId string = spokeVnetModule.outputs.spokeVnetId
output vmId string = vmModule.outputs.vmId
output privateDnsZoneId string = privateDnsModule.outputs.zoneId
output privateEndpointName string = storagePrivateEndpoint.outputs.privateEndpointName
output loadBalancerId string = loadBalancerModule.outputs.loadBalancerId
output loadBalancerName string = loadBalancerModule.outputs.loadBalancerName
output loadBalancerBackendPoolId string = loadBalancerModule.outputs.backendPoolId
