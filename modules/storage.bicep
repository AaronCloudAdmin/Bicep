param storageAccountName string
param location string
param environment string
param owner string

resource storageAccount 'Microsoft.Storage/storageAccounts@2023-01-01' = {
  name: storageAccountName
  location: location
  sku: {
    name: 'Standard_LRS'
  }
  kind: 'StorageV2'
  properties: {
    publicNetworkAccess: 'Disabled' // <-- This forces all traffic through the Private Endpoint!
    minimumTlsVersion: 'TLS1_2'
  }
  tags: {
    Environment: environment
    Owner: owner
    ManagedBy: 'Bicep'
  }
}

output storageAccountId string = storageAccount.id
output storageAccountName string = storageAccount.name
output storageEndpoint string = storageAccount.properties.primaryEndpoints.blob
