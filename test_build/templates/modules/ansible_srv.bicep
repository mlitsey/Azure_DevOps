param vmName string = 'afrl-acl-ansible-ctrl01-vm'
param location string = resourceGroup().location
param vnetName string = '/subscriptions/9310e78f-da66-467a-b10f-ce81130be3ad/resourceGroups/AZ-GV-DOD-AF-CCE-AFMC-P-IL5-AFRL-NET-RGP-01/providers/Microsoft.Network/virtualNetworks/AZ-GV-DOD-AF-CCE-AFMC-P-IL5-AFRL-VNT-01'
param subnetName string = 'AZ-GV-DOD-AF-CCE-AFMC-P-IL5-AFRL-VDI-SNT-01'
param adminUsername string = 'ansibleadm'
//@secure()
//param adminPassword string
param diskEncryptionSetId string = '/subscriptions/9310e78f-da66-467a-b10f-ce81130be3ad/resourceGroups/AZ-GV-DOD-AF-CCE-AFMC-P-IL5-AFRL-APP-RGP-02/providers/Microsoft.Compute/diskEncryptionSets/afrl-acl-shared-des'
param dataDisk_0_name string = '${vmName}_DataDisk_00'
param dataDisk_0_sku string = 'Premium_LRS:Premium'
param vmSize string = 'Standard_D4as_v5'

// @description('Name of the existing Key Vault')
// param keyVaultName string
//param sshPublicKey string

@allowed([
  'RedHat:RHEL:9-lvm-gen2:latest'
  'RedHat:RHEL:9-lvm:latest'
])
param imageReference string = 'RedHat:RHEL:9-lvm-gen2:latest'
param tagValues object = {
  Application: 'Shared_Services'
  costCenter: 'ACL'
  Environment: 'PROD'
  mission_application: 'AFRL'
  Region: 'USGovVirginia'
  ResourceGroup: resourceGroup().name
}


resource ansibleadm_key 'Microsoft.Compute/sshPublicKeys@2024-11-01' existing = {
  name: 'ansibleadm'
}

// resource vnet 'Microsoft.Network/virtualNetworks@2023-05-01' existing = {
//   name: vnetName
// }

// resource subnet 'Microsoft.Network/virtualNetworks/subnets@2023-05-01' existing = {
//   parent: vnet
//   name: subnetName
// }

resource nic 'Microsoft.Network/networkInterfaces@2023-05-01' = {
  name: '${vmName}-nic'
  location: location
  tags: tagValues
  properties: {
    ipConfigurations: [
      {
        name: 'ipconfig1'
        properties: {
          privateIPAllocationMethod: 'Dynamic'
          subnet: {
            id: '${vnetName}/subnets/${subnetName}'
          }
        }
      }
    ]
  }
}

resource dataDisk_0_resource 'Microsoft.Compute/disks@2025-01-02' = {
  name: dataDisk_0_name
  location: location
  tags: tagValues
  sku: {
    name: split(dataDisk_0_sku, ':')[0]
    //tier: split(dataDisk_0_sku, ':')[1]
  }
  properties: {
    creationData: {
      createOption: 'Empty'
    }
    diskSizeGB: 128
    diskIOPSReadWrite: 1100
    diskMBpsReadWrite: 125
    encryption: {
      type: 'EncryptionAtRestWithCustomerKey'
      diskEncryptionSetId: diskEncryptionSetId
    }
    networkAccessPolicy: 'AllowAll'
    publicNetworkAccess: 'Enabled'
    tier: 'P15'
  }
}

resource vm 'Microsoft.Compute/virtualMachines@2023-03-01' = {
  name: vmName
  location: location
  tags: tagValues
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    hardwareProfile: {
      vmSize: vmSize
    }
    osProfile: {
      computerName: vmName
      adminUsername: adminUsername
      //adminPassword: adminPassword
      linuxConfiguration: {
        disablePasswordAuthentication: true
        ssh: {
          publicKeys: [
            {
              keyData: ansibleadm_key.properties.publicKey
              path: '/home/${adminUsername}/.ssh/authorized_keys'
            }
          ]
        }
        provisionVMAgent: true
        patchSettings: {
          patchMode: 'ImageDefault'
          assessmentMode: 'ImageDefault'
        }
      }
      secrets: []
      allowExtensionOperations: true
      //requireGuestProvisionSignal: true
    }
    storageProfile: {
      imageReference: {
        publisher: split(imageReference, ':')[0]
        offer: split(imageReference, ':')[1]
        sku: split(imageReference, ':')[2]
        version: split(imageReference, ':')[3]
      }
      osDisk: {
        osType: 'Linux'
        name: '${vmName}_OsDisk'
        createOption: 'FromImage'
        caching: 'None'
        managedDisk: {
          diskEncryptionSet: {
            id: diskEncryptionSetId
          }
          storageAccountType: 'Premium_LRS'
        }
        deleteOption: 'Delete'
        diskSizeGB: 128
      }
      dataDisks: [
        {
          lun: 0 
          name: dataDisk_0_name
          createOption: 'Attach'
          caching: 'None'
          writeAcceleratorEnabled: false
          managedDisk: {
            id: dataDisk_0_resource.id
          }
          deleteOption: 'Detach'
          toBeDetached: false
        }
      ]
      diskControllerType: 'SCSI'
    }
    networkProfile: {
      networkInterfaces: [
        {
          id: nic.id
        }
      ]
    }
    diagnosticsProfile: {
      bootDiagnostics: {
        enabled: true
      }
    }
    securityProfile: {
      uefiSettings: {
        secureBootEnabled: true
        vTpmEnabled: true
      }
      securityType: 'TrustedLaunch'
    }
  }
}
