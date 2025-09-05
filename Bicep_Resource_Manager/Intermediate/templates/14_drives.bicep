@description('Base name for all resources')
param name string = 'dsk-test'

@description('hostname for vm')
@maxLength(15)
param hostName string = 'testvm'

@description('Location for all resources')
param location string = resourceGroup().location

@description('Existing subnet resource ID to place the NIC in')
param subnetId string = '/subscriptions/b80bca1c-8674-4916-831b-1982e1866120/resourceGroups/work-test/providers/Microsoft.Network/virtualNetworks/test-vnet/subnets/default'

@description('Create a public IP for the VM')
param createPublicIP bool = true

@description('Admin username for the VM')
param adminUsername string = 'azureuser'

@secure()
param adminPassword string

@description('SSH public key (e.g. contents of ~/.ssh/id_rsa.pub)')
//@secure()
param adminSshPublicKey string = 'ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBNqvMY8Ws7XjxwfLQahKIYJZYebHXDOOultQZhf1xRX mlitsey@DESKTOP-G2CISOE'

@description('VM size (ensure it supports your disk count/perf needs)')
@allowed( [
  'Standard_D8alds_v6'
  'Standard_D8s_v6'
])
param vmSize string = 'Standard_D8s_v6'

@description('How many data disks to attach')
@minValue(1)
@maxValue(32)
param diskCount int = 16

@description('Size of each data disk in GiB')
@minValue(4)
param diskSizeGiB int = 4

@description('Managed disk SKU for data disks. Premium SSD v2 is NVMe-backed.')
@allowed([
  'PremiumV2_LRS'
  'Premium_LRS'
  'StandardSSD_LRS'
  'UltraSSD_LRS' // if you switch to Ultra, set ultraSSDEnabled below
])
param dataDiskSku string = 'PremiumV2_LRS'

@description('Enable Ultra disk capability on the VM (only if using UltraSSD_LRS).')
param ultraSSDEnabled bool = false

// Networking
resource pip 'Microsoft.Network/publicIPAddresses@2023-11-01' = if (createPublicIP) {
  name: '${name}-pip'
  location: location
  sku: {
    name: 'Standard'
  }
  properties: {
    publicIPAllocationMethod: 'Static'
  }
}

resource nic 'Microsoft.Network/networkInterfaces@2023-11-01' = {
  name: '${name}-nic'
  location: location
  properties: {
    enableAcceleratedNetworking: true
    ipConfigurations: [
      {
        name: 'ipconfig1'
        properties: {
          privateIPAllocationMethod: 'Dynamic'
          subnet: {
            id: subnetId
          }
          publicIPAddress: createPublicIP ? {
            id: pip.id
          } : null
        }
      }
    ]
  }
}

// Data disks (managed)
resource dataDisks 'Microsoft.Compute/disks@2023-04-02' = [for i in range(2, diskCount): {
  name: '${name}-data-${(i)}'
  location: location
  sku: {
    name: dataDiskSku
  }
  properties: {
    creationData: {
      createOption: 'Empty'
    }
    diskSizeGB: diskSizeGiB
  }
  zones: [
    '1'
  ]
}]

// VM
resource vm 'Microsoft.Compute/virtualMachines@2023-09-01' = {
  name: name
  location: location
  zones: ['1'] // optional: specify ['1'] | ['2'] | ['3'] if you want a zone
  properties: {
    hardwareProfile: {
      vmSize: vmSize
    }
    additionalCapabilities: {
      ultraSSDEnabled: ultraSSDEnabled
    }
    osProfile: {
      computerName: hostName
      adminUsername: adminUsername
      adminPassword: adminPassword
      linuxConfiguration: {
        disablePasswordAuthentication: false
        ssh: {
          publicKeys: [
            {
              path: '/home/${adminUsername}/.ssh/authorized_keys'
              keyData: adminSshPublicKey
            }
          ]
        }
      }
    }
    storageProfile: {
      imageReference: {
        publisher: 'RedHat'
        offer: 'RHEL'
        sku: '9-lvm-gen2'
        version: 'latest'
      }
      osDisk: {
        createOption: 'FromImage'
        caching: 'ReadWrite'
        diskSizeGB: 64
        managedDisk: {
          storageAccountType: 'Premium_LRS'
        }
      }
      dataDisks: [for j in range(0, diskCount): {
        lun: (j + 2)
        name: dataDisks[j].name
        createOption: 'Attach'
        managedDisk: {
          id: dataDisks[j].id
        }
        caching: 'None' // often best for data disks; change to ReadWrite if needed
      }]
      diskControllerType: 'NVMe'
    }
    networkProfile: {
      networkInterfaces: [
        {
          id: nic.id
          properties: {
            primary: true
          }
        }
      ]
    }
  }
}

// Handy outputs
output vmId string = vm.id
output vmPrivateIP string = nic.properties.ipConfigurations[0].properties.privateIPAddress
output publicIP string = createPublicIP ? pip.properties.ipAddress : 'none'
