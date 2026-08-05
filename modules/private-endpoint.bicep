@description('The Azure region where the private endpoint will be deployed.')
param location string

@description('The resource ID of the target storage account.')
param storageAccountId string

@description('The name of the target storage account.')
param storageAccountName string

@description('The subnet ID within the Spoke VNet where the private endpoint NIC will reside.')
param subnetId string

@description('The Virtual Network ID for the private DNS zone link.')
param vnetId string

@description('Environment tag.')
param environmentName string = 'dev'

@description('Owner tag.')
param owner string = 'Aaron'

// 1. Private Endpoint Resource
resource privateEndpoint 'Microsoft.Network/privateEndpoints@2023-09-01' = {
  name: 'pe-${storageAccountName}-blob'
  location: location
  tags: {
    Environment: environmentName
    Owner: owner
    ManagedBy: 'Bicep'
  }
  properties: {
    subnet: {
      id: subnetId
    }
    privateLinkServiceConnections: [
      {
        name: 'plsc-${storageAccountName}'
        properties: {
          privateLinkServiceId: storageAccountId
          groupIds: [
            'blob'
          ]
        }
      }
    ]
  }
}

// 2. Private DNS Zone for Blob Storage
resource privateDnsZone 'Microsoft.Network/privateDnsZones@2020-06-01' = {
  name: 'privatelink.blob.${environment().suffixes.storage}'
  location: 'global'
}

// 3. Virtual Network Link to Spoke VNet
resource dnsZoneLink 'Microsoft.Network/privateDnsZones/virtualNetworkLinks@2020-06-01' = {
  parent: privateDnsZone
  name: 'link-${uniqueString(vnetId)}'
  location: 'global'
  properties: {
    registrationEnabled: false
    virtualNetwork: {
      id: vnetId
    }
  }
}

// 4. Private DNS Zone Group (Automates DNS A-Record creation)
resource dnsZoneGroup 'Microsoft.Network/privateEndpoints/privateDnsZoneGroups@2023-09-01' = {
  parent: privateEndpoint
  name: 'default'
  properties: {
    privateDnsZoneConfigs: [
      {
        name: 'config-blob'
        properties: {
          privateDnsZoneId: privateDnsZone.id
        }
      }
    ]
  }
}

// Outputs
output privateEndpointName string = privateEndpoint.name
output privateEndpointId string = privateEndpoint.id
