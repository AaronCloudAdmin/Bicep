// Shared_Modules/vnet.bicep

@description('The custom, dynamic name of the Virtual Network')
param vnetName string

@description('The Azure region where the resouce will be deployed')
param location string

@description('The addess space for the VNet')
param addressPrefixes array

// The resource declaration
resource virtualNetwork 'Microsoft.Network/virtualNetworks@2023-09-01' = {
  name: vnetName
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: addressPrefixes
    }
  }
}

// Output the ID so the main template can use it if needed
output vnetId string = virtualNetwork.id
