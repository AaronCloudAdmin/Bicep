param vnetName string
param location string
param environmentName string
param owner string
param nsgId string // <--- Added parameter for the baseline NSG

resource virtualNetwork 'Microsoft.Network/virtualNetworks@2023-09-01' = {
  name: vnetName
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: [
        '10.0.0.0/16'
      ]
    }
    subnets: [
      {
        name: 'GatewaySubnet'
        properties: {
          addressPrefix: '10.0.0.0/24'
          networkSecurityGroup: {
            id: nsgId // <--- Bound to Hub subnets
          }
        }
      }
      {
        name: 'AzureBastionSubnet'
        properties: {
          addressPrefix: '10.0.1.0/26'
          networkSecurityGroup: {
            id: nsgId // <--- Bound to Hub subnets
          }
        }
      }
      {
        name: 'shared-services-subnet'
        properties: {
          addressPrefix: '10.0.2.0/24'
          networkSecurityGroup: {
            id: nsgId // <--- Bound to Hub subnets
          }
        }
      }
    ]
  }
  tags: {
    Environment: environmentName
    Owner: owner
    ManagedBy: 'Bicep'
  }
}

output vnetId string = virtualNetwork.id
output vnetName string = virtualNetwork.name
