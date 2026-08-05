// modules/nsg.bicep - Network Security Group Blueprint
param nsgName string
param location string
param environmentName string
param owner string

resource nsg 'Microsoft.Network/networkSecurityGroups@2023-09-01' = {
  name: nsgName
  location: location
  properties: {
    securityRules: [
      {
        name: 'Allow-SSH-Inbound'
        properties: {
          priority: 100
          direction: 'Inbound'
          access: 'Allow'
          protocol: 'Tcp'
          sourceAddressPrefix: '*'
          sourcePortRange: '*'
          destinationAddressPrefix: '*'
          destinationPortRange: '22'
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

output nsgId string = nsg.id
