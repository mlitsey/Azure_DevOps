@description('Location for resource group specified on command line')
param location string = resourceGroup().location
@description('lower case, non hyphanated version of resource group name to prevent naming issues')
param rg_name string = 'testrgp01'
@allowed([
  'shared'
  'application'
])
param envType string
param tagValues object = {
  Environment: 'Production'
  ResourceGroup: resourceGroup().name
  Application: 'Shared_Services'
}
//param keyVaultName string = '${uniqueString(resourceGroup().id)}-kv'
//param keyVaultName string = '${rg_name}-kv'
@minLength(3)
@maxLength(24)
param keyVaultName string = '${resourceGroup().name}-kv'
@minLength(5)
@maxLength(50)
param acrName string = '${rg_name}acr'
@minLength(3)
@maxLength(24)
param storageAccountName string = '${rg_name}st'

@description('Key Vault for Resource Group')
resource keyVault 'Microsoft.KeyVault/vaults@2024-12-01-preview' = {
  name: keyVaultName
  location: location
  tags: tagValues
  properties: {
    createMode: 'default'
    enabledForDeployment: true
    enabledForDiskEncryption: false
    enabledForTemplateDeployment: true
    enableSoftDelete: true
    enableRbacAuthorization: true
    enablePurgeProtection: true
    sku: {
      family: 'A'
      name: 'standard'
    }
    softDeleteRetentionInDays: 90
    tenantId: subscription().tenantId
  }
}

@description('Container Registry for shared resources')
resource containerRegistry 'Microsoft.ContainerRegistry/registries@2025-04-01' = if (envType == 'shared') {
  location: location
  name: acrName
  tags: tagValues
  sku: {
    name: 'Standard'
  }
  properties: {
    adminUserEnabled: true
  }
}

@description('Storage Account for Resource Group')
module storage_acct 'modules/storage_acct.bicep' = {
  //name: storageAccountName
  params: {
    location: location
    storageAccountName: storageAccountName
  }
}

module aksModule './modules/aks.bicep' = {
  name: 'aksMinimal'
  params: {
    name: 'myMinimalAks'
    dnsPrefix: 'myaksdns'
  }
}
