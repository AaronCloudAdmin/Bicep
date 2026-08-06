@description('The name of the Spoke Virtual Network.')
param vnetName string

@description('The Azure region where the VNet will be deployed.')
param location string

@description('Environment tag.')
param environmentName string

@description('Owner tag.')
param owner string

@description('The Resource ID of the Network Security Group to apply to the workload subnet.')
param nsgId string // <--- Added parameter

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
          // Attach the baseline NSG to the Spoke workload subnet
          networkSecurityGroup: {
            id: nsgId
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

output spokeVnetId string = spokeVNet.id
output spokeVnetName string = spokeVNet.name
output workloadSubnetId string = spokeVNet.properties.subnets[0].id
