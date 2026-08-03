// modules/spoke-vnet.bicep - Spoke Workload Virtual Network
param vnetName string
param location string
param environment string
param owner string

resource spokeVNet 'Microsoft.Network/virtualNetworks@2023-09-01' = {
  name: vnetName
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: [
        '10.1.0.0/16'
      ]
    }
    subnets: [
      {
        name: 'workload-subnet'
        properties: {
          addressPrefix: '10.1.1.0/24'
        }
      }
    ]
  }
  tags: {
    Environment: environment
    Owner: owner
    ManagedBy: 'Bicep'
  }
}

output spokeVnetId string = spokeVNet.id
output spokeVnetName string = spokeVNet.name
