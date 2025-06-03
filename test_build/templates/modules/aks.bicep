param name string
param location string = resourceGroup().location
param dnsPrefix string
param kubernetesVersion string = '1.29.2'
param nodeCount int = 1
param nodeVMSize string = 'Standard_DS2_v2'

resource aks 'Microsoft.ContainerService/managedClusters@2024-01-01' = {
  name: name
  location: location
  properties: {
    dnsPrefix: dnsPrefix
    kubernetesVersion: kubernetesVersion
    agentPoolProfiles: [
      {
        name: 'systempool'
        count: nodeCount
        vmSize: nodeVMSize
        osType: 'Linux'
        mode: 'System'
        type: 'VirtualMachineScaleSets'
      }
    ]
    //identity: {
    //  type: 'SystemAssigned'
    //}
    enableRBAC: true
  }
}

output aksClusterName string = aks.name
output aksFqdn string = aks.properties.fqdn
