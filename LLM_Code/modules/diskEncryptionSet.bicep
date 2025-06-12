@description('Name of the disk encryption set')
param name string

@description('Location for resources')
param location string = resourceGroup().location

@description('Name of the existing Key Vault')
param keyVaultName string

@description('Name of the CMK to create/use in Key Vault')
param cmkName string

@description('Enable key rotation for CMK')
param enableKeyRotation bool = true

@description('Key vault access object ID for DES (e.g. from `azurerm_disk_encryption_set` managed identity)')
param tenantId string

resource keyVault 'Microsoft.KeyVault/vaults@2023-02-01' existing = {
  name: keyVaultName
}

// Create CMK (RSA 4096)
resource cmk 'Microsoft.KeyVault/vaults/keys@2023-02-01' = {
  parent: keyVault
  name: cmkName
  properties: {
    kty: 'RSA'
    keySize: 4096
    keyOps: [
      'wrapKey'
      'unwrapKey'
    ]
    attributes: {
      enabled: true
    }
  }
}

// Enable rotation (optional)
resource rotationPolicy 'Microsoft.KeyVault/vaults/keys/rotationPolicy@2023-02-01' = if (enableKeyRotation) {
  parent: cmk
  name: 'default'
  properties: {
    lifetimeActions: [
      {
        trigger: {
          timeAfterCreate: 'P90D'
        }
        action: {
          type: 'Rotate'
        }
      }
    ]
    expiryTime: 'P180D'
  }
}

// Disk Encryption Set
resource des 'Microsoft.Compute/diskEncryptionSets@2023-03-01' = {
  name: name
  location: location
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    activeKey: {
      keyUrl: cmk.properties.keyUriWithVersion
      sourceVault: {
        id: keyVault.id
      }
    }
    encryptionType: 'EncryptionAtRestWithCustomerKey'
  }
}

// Key Vault access policy to allow DES to access CMK
resource desAccessPolicy 'Microsoft.KeyVault/vaults/accessPolicies@2023-02-01' = {
  name: '${keyVault.name}/add'
  properties: {
    accessPolicies: [
      {
        tenantId: tenantId
        objectId: des.identity.principalId
        permissions: {
          keys: [
            'get'
            'wrapKey'
            'unwrapKey'
          ]
        }
      }
    ]
  }
  dependsOn: [
    des
  ]
}


output desId string = des.id
output desIdentityPrincipalId string = des.identity.principalId
output cmkUri string = cmk.properties.keyUriWithVersion


