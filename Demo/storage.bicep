param location string = resourceGroup().location
param accountName string = 'st$[uniquestring(resourceGroup().id)]'
param skuName string = 'Standard_LRS'

resource storageaccount 'Microsoft.Storage/storageAccounts@2022-09-01' = {
  name: 'name'
  location: location
  sku: {
    name: 'skuName'
  }
  kind: 'StorageV2'
  properties: {
    accessTier: 'Cool'
  }
}

output storageAccountName string = storageaccount.name
