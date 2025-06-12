param name string
param location string = resourceGroup().location
param vnetId string
param subnetName string

param keyVaultName string
param cmkName string = '${name}-cmk'
param enablePrivateEndpoint bool = true
param allowBlobPublicAccess bool = false

// Reference existing Key Vault
resource keyVault 'Microsoft.KeyVault/vaults@2023-02-01' existing = {
  name: keyVaultName
}

// Create a CMK in Key Vault
resource key 'Microsoft.KeyVault/vaults/keys@2023-02-01' = {
  parent: keyVault
  name: cmkName
  properties: {
    keySize: 4096
    kty: 'RSA'
    keyOps: [
      'encrypt'
      'decrypt'
      'wrapKey'
      'unwrapKey'
    ]
  }
}

// Storage Account with CMK encryption
resource storageAccount 'Microsoft.Storage/storageAccounts@2023-01-01' = {
  name: name
  location: location
  sku: {
    name: 'Standard_LRS'
  }
  kind: 'StorageV2'
  properties: {
    accessTier: 'Hot'
    allowBlobPublicAccess: allowBlobPublicAccess
    minimumTlsVersion: 'TLS1_2'
    supportsHttpsTrafficOnly: true
    encryption: {
      keySource: 'Microsoft.Keyvault'
      keyvaultproperties: {
        keyname: key.name
        keyvaulturi: keyVault.properties.vaultUri
      }
      services: {
        blob: {
          enabled: true
        }
        file: {
          enabled: true
        }
      }
    }
    networkAcls: {
      bypass: 'AzureServices'
      defaultAction: enablePrivateEndpoint ? 'Deny' : 'Allow'
    }
  }
}

// Private endpoint for the Storage Account
resource privateEndpoint 'Microsoft.Network/privateEndpoints@2023-05-01' = if (enablePrivateEndpoint) {
  name: '${name}-pe'
  location: location
  properties: {
    subnet: {
      id: '${vnetId}/subnets/${subnetName}'
    }
    privateLinkServiceConnections: [
      {
        name: '${name}-plsc'
        properties: {
          privateLinkServiceId: storageAccount.id
          groupIds: [
            'blob'
          ]
        }
      }
    ]
  }
}

output storageAccountName string = storageAccount.name
output storageAccountId string = storageAccount.id
output cmkUri string = key.properties.keyUriWithVersion
