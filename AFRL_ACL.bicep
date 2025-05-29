@description('Location for Shared Services')
param location string = 'eastus'

@description('Resource Group Name')
param rgName string = 'shared_services'

@description('Variable for Resource Group')
var sharedServicesRG = {
  name: rgName
  location: location
}

@description('Virtual Machine: RHEL 9 STIG')
resource rhelVm 'Microsoft.Compute/virtualMachines@2021-11-01' = {
  name: 'rhel9-stig-vm'
  location: sharedServicesRG.location
  properties: {
    hardwareProfile: {
      vmSize: 'Standard_D2s_v3'
    }
    osProfile: {
      computerName: 'rhel9vm'
      adminUsername: 'adminuser'
      linuxConfiguration: {
        disablePasswordAuthentication: true
      }
    }
    storageProfile: {
      imageReference: {
        publisher: 'RedHat'
        offer: 'RHEL'
        sku: '9-lvm'
        version: 'latest'
      }
      osDisk: {
        createOption: 'FromImage'
      }
    }
  }
}

@description('GitLab CE Deployment')
resource gitlabCE 'Microsoft.Compute/virtualMachines@2021-11-01' = {
  name: 'gitlab-ce'
  location: sharedServicesRG.location
  properties: {
    hardwareProfile: {
      vmSize: 'Standard_D2s_v3'
    }
    storageProfile: {
      imageReference: {
        publisher: 'Canonical'
        offer: 'UbuntuServer'
        sku: '18.04-LTS'
        version: 'latest'
      }
      osDisk: {
        createOption: 'FromImage'
      }
    }
  }
}

@description('Minimal AKS Cluster')
resource aksCluster 'Microsoft.ContainerService/managedClusters@2021-03-01' = {
  name: 'aks-cluster'
  location: sharedServicesRG.location
  properties: {
    dnsPrefix: 'aksdns'
    agentPoolProfiles: [{
      name: 'nodepool1'
      count: 1
      vmSize: 'Standard_B2s'
    }]
    addonProfiles: {
      certManager: {
        enabled: true
      }
    }
  }
}

@description('Application Gateways')
resource appGateway1 'Microsoft.Network/applicationGateways@2021-03-01' = {
  name: 'appgw1'
  location: sharedServicesRG.location
  properties: {
    gatewayIpConfigurations: [{
      name: 'gwip1'
      subnet: {
        id: '<subnet-id>'
      }
    }]
  }
}

resource appGateway2 'Microsoft.Network/applicationGateways@2021-03-01' = {
  name: 'appgw2'
  location: sharedServicesRG.location
  properties: {
    gatewayIpConfigurations: [{
      name: 'gwip2'
      subnet: {
        id: '<subnet-id>'
      }
    }]
  }
}
