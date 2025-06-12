module keyVaultModule './modules/keyVault.bicep' = {
  name: 'deployKeyVault'
  params: {
    name: 'gov-il5-kv'
    tenantId: subscription().tenantId
    objectId: '00000000-0000-0000-0000-000000000000' // Your user/service principal/objectId
    vnetId: resourceId('Microsoft.Network/virtualNetworks', 'gov-il5-vnet')
    subnetName: 'kv-subnet'
  }
}

module storageModule './modules/storage.bicep' = {
  name: 'deployStorageAccount'
  params: {
    name: 'govil5storage'
    location: 'usgovvirginia'
    keyVaultName: 'gov-il5-kv'
    vnetId: resourceId('Microsoft.Network/virtualNetworks', 'gov-il5-vnet')
    subnetName: 'storage-subnet'
  }
}

module desModule './modules/diskEncryptionSet.bicep' = {
  name: 'createDES'
  params: {
    name: 'govil5-des'
    keyVaultName: 'gov-il5-kv'
    cmkName: 'govil5-cmk'
    tenantId: subscription().tenantId
  }
}

module ansible './modules/ansibleServer.bicep' = {
  name: 'deployAnsible'
  params: {
    name: 'ansible-server'
    vnetName: 'govil5-vnet'
    subnetName: 'ansible-subnet'
    adminUsername: 'azureadmin'
    adminPassword: '<<secure>>'
    diskEncryptionSetId: desModule.outputs.desId
  }
}

