param name string = 'ansible-server'
param location string = resourceGroup().location
param vnetName string
param subnetName string
param adminUsername string
@secure()
param adminPassword string
param diskEncryptionSetId string = ''
param vmSize string = 'Standard_D4s_v5'

@allowed([
  'RedHat:RHEL:9_3:latest'
  'RedHat:RHEL:9-lvm:latest'
])
param imageReference string = 'RedHat:RHEL:9_3:latest'

resource vnet 'Microsoft.Network/virtualNetworks@2023-05-01' existing = {
  name: vnetName
}

resource subnet 'Microsoft.Network/virtualNetworks/subnets@2023-05-01' existing = {
  parent: vnet
  name: subnetName
}

resource nic 'Microsoft.Network/networkInterfaces@2023-05-01' = {
  name: '${name}-nic'
  location: location
  properties: {
    ipConfigurations: [
      {
        name: 'ipconfig1'
        properties: {
          privateIPAllocationMethod: 'Dynamic'
          subnet: {
            id: subnet.id
          }
        }
      }
    ]
  }
}

resource vm 'Microsoft.Compute/virtualMachines@2023-03-01' = {
  name: name
  location: location
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    hardwareProfile: {
      vmSize: vmSize
    }
    osProfile: {
      computerName: name
      adminUsername: adminUsername
      adminPassword: adminPassword
      linuxConfiguration: {
        disablePasswordAuthentication: false
        provisionVMAgent: true
      }
      //customData: base64(interpolate('#cloud-config
      //  packages:
      //    - ansible
      //  runcmd:
      //    - echo "Ansible installed"
      //'))
    }
    storageProfile: {
      imageReference: {
        publisher: split(imageReference, ':')[0]
        offer: split(imageReference, ':')[1]
        sku: split(imageReference, ':')[2]
        version: split(imageReference, ':')[3]
      }
      osDisk: {
        createOption: 'FromImage'
        managedDisk: {
          storageAccountType: 'Premium_LRS'
          securityProfile: diskEncryptionSetId != '' ? {
            diskEncryptionSet: {
              id: diskEncryptionSetId
            }
          } : null
        }
      }
    }
    networkProfile: {
      networkInterfaces: [
        {
          id: nic.id
        }
      ]
    }
  }
}
