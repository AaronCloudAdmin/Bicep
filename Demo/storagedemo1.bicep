param location string = resourceGroup().location

@minLength(3)
@maxLength(24)
param name string = 'ahbicepstoragedemo01'

@allowed([
  'Standard_LRS'
  'Standard_GRS'
  'Standard_ZRS'
  'Standard_RAGRS'
])
param type string = 'Standard_LRS'

resource stacc 'Microsoft.Storage/storageAccounts@2026-04-01' = {
  name: name
  location: location
  kind: 'StorageV2'
  sku: {
    name: type
  }
}

resource container 'Microsoft.Storage/storageAccounts/blobServices/containers@2023-01-01' = {
  parent: blobService
  name: '${stacc.name}/default/images}'
}

output strageId string = stacc.id
