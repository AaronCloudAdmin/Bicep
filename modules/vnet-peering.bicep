// modules/vnet-peering.bicep - Virtual Network Peering Connection
param peeringName string
param localVnetName string
param remoteVnetId string

// Declare the local VNet as an existing resource so Bicep can nest the peering under it
resource localVNet 'Microsoft.Network/virtualNetworks@2023-09-01' existing = {
  name: localVnetName
}

resource vnetPeering 'Microsoft.Network/virtualNetworks/virtualNetworkPeerings@2023-09-01' = {
  name: peeringName
  parent: localVNet
  properties: {
    remoteVirtualNetwork: {
      id: remoteVnetId
    }
    allowVirtualNetworkAccess: true
    allowForwardedTraffic: true
    allowGatewayTransit: false
    useRemoteGateways: false
  }
}
