@description('The Azure region where the load balancer will be deployed.')
param location string

@description('The name of the load balancer.')
param lbName string = 'lb-workload-01'

@description('Environment tag.')
param environment string = 'dev'

@description('Owner tag.')
param owner string = 'Aaron'

// 1. Standard Public IP (Mandatory pairing for Standard SKU Load Balancers)
resource publicIp 'Microsoft.Network/publicIPAddresses@2023-09-01' = {
  name: 'pip-${lbName}'
  location: location
  sku: {
    name: 'Standard'
    tier: 'Regional'
  }
  properties: {
    publicIPAllocationMethod: 'Static'
    publicIPAddressVersion: 'IPv4'
  }
}

// 2. Standard Load Balancer (Layer 4)
resource loadBalancer 'Microsoft.Network/loadBalancers@2023-09-01' = {
  name: lbName
  location: location
  sku: {
    name: 'Standard'
    tier: 'Regional'
  }
  tags: {
    Environment: environment
    Owner: owner
    ManagedBy: 'Bicep'
  }
  properties: {
    frontendIPConfigurations: [
      {
        name: 'fe-ip-config'
        properties: {
          publicIPAddress: {
            id: publicIp.id
          }
        }
      }
    ]
    backendAddressPools: [
      {
        name: 'bepool-workloads'
      }
    ]
    loadBalancingRules: [
      {
        name: 'rule-http'
        properties: {
          frontendIPConfiguration: {
            id: resourceId('Microsoft.Network/loadBalancers/frontendIPConfigurations', lbName, 'fe-ip-config')
          }
          backendAddressPool: {
            id: resourceId('Microsoft.Network/loadBalancers/backendAddressPools', lbName, 'bepool-workloads')
          }
          probe: {
            id: resourceId('Microsoft.Network/loadBalancers/probes', lbName, 'probe-http')
          }
          protocol: 'Tcp'
          frontendPort: 80
          backendPort: 80
          enableTcpReset: true
          idleTimeoutInMinutes: 4
        }
      }
    ]
    probes: [
      {
        name: 'probe-http'
        properties: {
          protocol: 'Tcp'
          port: 80
          intervalInSeconds: 15
          numberOfProbes: 2
        }
      }
    ]
  }
}

// Outputs
output loadBalancerId string = loadBalancer.id
output loadBalancerName string = loadBalancer.name
output backendPoolId string = loadBalancer.properties.backendAddressPools[0].id
