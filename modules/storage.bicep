// modules/storage.bicep - Secure Storage Account Blueprint
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
    minimumTlsVersion: 'TLS1_2'
    supportsHttpsTrafficOnly: true
    allowBlobPublicAccess: false
  }
  tags: {
    Environment: environment
    Owner: owner
    ManagedBy: 'Bicep'
  }
}

output storageEndpoint string = storageAccount.properties.primaryEndpoints.blob
