param name string
param location string = resourceGroup().location
param tenantId string
param objectId string  // Object ID of user or app needing access
param skuName string = 'premium' // 'premium' required for HSM-backed keys
param enablePurgeProtection bool = true
param enableSoftDelete bool = true
param enablePrivateEndpoint bool = true
param vnetId string = '' // Required if private endpoint is enabled
param subnetName string = '' // Name of subnet for the private endpoint

resource keyVault 'Microsoft.KeyVault/vaults@2023-02-01' = {
  name: name
  location: location
  properties: {
    tenantId: tenantId
    sku: {
      name: skuName
      family: 'A'
    }
    accessPolicies: [
      {
        tenantId: tenantId
        objectId: objectId
        permissions: {
          keys: [
            'get'
            'list'
            'create'
            'delete'
            'recover'
            'backup'
            'restore'
            'import'
          ]
          secrets: [
            'get'
            'list'
            'set'
            'delete'
            'recover'
          ]
        }
      }
    ]
    enablePurgeProtection: enablePurgeProtection
    enableSoftDelete: enableSoftDelete
    enabledForDeployment: true
    enabledForTemplateDeployment: true
    enabledForDiskEncryption: true
    publicNetworkAccess: enablePrivateEndpoint ? 'Disabled' : 'Enabled'
    networkAcls: {
      bypass: 'AzureServices'
      defaultAction: enablePrivateEndpoint ? 'Deny' : 'Allow'
    }
  }
}

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
          privateLinkServiceId: keyVault.id
          groupIds: [
            'vault'
          ]
        }
      }
    ]
  }
}

output vaultUri string = keyVault.properties.vaultUri
