param location string = resourceGroup().location
param vmName string = 'win11-ansiblevm'
param adminUsername string = 'ansibleadmin'
param keyVaultName string
param secretName string = 'ansibleadmin-password'
param kvKeyName string = 'ansibleDiskKey' // name of key in key vault
param subnetId string
param nicName string = '${vmName}-nic'
param desName string = '${vmName}-des'

resource keyVault 'Microsoft.KeyVault/vaults@2023-02-01' existing = {
  name: keyVaultName
}

resource secret 'Microsoft.KeyVault/vaults/secrets@2023-02-01' existing = {
  parent: keyVault
  name: secretName
}

resource kvKey 'Microsoft.KeyVault/vaults/keys@2023-02-01' existing = {
  parent: keyVault
  name: kvKeyName
}

resource des 'Microsoft.Compute/diskEncryptionSets@2023-03-01' = {
  name: desName
  location: location
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    activeKey: {
      sourceVault: {
        id: keyVault.id
      }
      keyUrl: kvKey.properties.keyUriWithVersion
    }
    encryptionType: 'EncryptionAtRestWithCustomerKey'
  }
}

//resource publicIP 'Microsoft.Network/publicIPAddresses@2023-05-01' = {
//  name: '${vmName}-pip'
//  location: location
//  sku: {
//    name: 'Basic'
//  }
//  properties: {
//    publicIPAllocationMethod: 'Dynamic'
//  }
//}

resource nic 'Microsoft.Network/networkInterfaces@2023-05-01' = {
  name: nicName
  location: location
  properties: {
    ipConfigurations: [
      {
        name: 'ipconfig1'
        properties: {
          privateIPAllocationMethod: 'Dynamic'
          //publicIPAddress: {
          //  id: publicIP.id
          //}
          subnet: {
            id: subnetId
          }
        }
      }
    ]
  }
}

resource vm 'Microsoft.Compute/virtualMachines@2023-03-01' = {
  name: vmName
  location: location
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    hardwareProfile: {
      vmSize: 'Standard_D4s_v5'
    }
    osProfile: {
      computerName: vmName
      adminUsername: adminUsername
      adminPassword: secret.properties.value
    }
    storageProfile: {
      imageReference: {
        publisher: 'MicrosoftWindowsDesktop'
        offer: 'windows-11'
        sku: 'win11-22h2-pro'
        version: 'latest'
      }
      osDisk: {
        createOption: 'FromImage'
        managedDisk: {
          storageAccountType: 'StandardSSD_LRS'
          diskEncryptionSet: {
            id: des.id
          }
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
