// main.bicep

@description('The target environment (e.g., dev, prod)')
param environment string = 'dev'

@description('The primary location for resources')
param location string = resourceGroup().location

// Array of workloads we want to create VNets for
var workloads = [
  'core'
  'web'
  'data'
]

// Loop through the workloads array to create multiple VNets
// Name format: vnet-[workload]-[environment]-[location]-001
module vnets 'Shared_Modules/vnet.bicep' = [
  for (workload, i) in workloads: {
    name: 'deploy-vnet-${workload}'
    params: {
      vnetName: 'vnet-${workload}-${environment}-${location}-001'
      location: location
      addressPrefixes: [
        '10.0.${i}.0/24'
      ]
    }
  }
]
