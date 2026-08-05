// modules/private-dns.bicep - Azure Private DNS Zone & VNet Links
param zoneName string
param hubVnetId string
param spokeVnetId string
param environment string
param owner string

// Private DNS Zones are always deployed to 'global' location in Azure
resource privateDnsZone 'Microsoft.Network/privateDnsZones@2020-06-01' = {
  name: zoneName
  location: 'global'
  tags: {
    Environment: environment
    Owner: owner
    ManagedBy: 'Bicep'
  }
}

// Link Zone to Hub VNet (with Auto-Registration enabled)
resource hubVnetLink 'Microsoft.Network/privateDnsZones/virtualNetworkLinks@2020-06-01' = {
  parent: privateDnsZone
  name: '${zoneName}-hub-link'
  location: 'global'
  properties: {
    registrationEnabled: true
    virtualNetwork: {
      id: hubVnetId
    }
  }
}

// Link Zone to Spoke VNet (Resolution only)
resource spokeVnetLink 'Microsoft.Network/privateDnsZones/virtualNetworkLinks@2020-06-01' = {
  parent: privateDnsZone
  name: '${zoneName}-spoke-link'
  location: 'global'
  properties: {
    registrationEnabled: false
    virtualNetwork: {
      id: spokeVnetId
    }
  }
}

output zoneId string = privateDnsZone.id
output zoneName string = privateDnsZone.name
