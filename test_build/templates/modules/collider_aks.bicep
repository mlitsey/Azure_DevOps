param managedClusters_ColliderPure_AKS_01_name string = 'ColliderPure-AKS-01'
param virtualNetworks_collider_vnet_sharedServices_test_externalid string = '/subscriptions/6f1491c1-f8e5-4335-8d95-f2d64080fcf0/resourceGroups/collider-rg-sharedServices-test/providers/Microsoft.Network/virtualNetworks/collider-vnet-sharedServices-test'
param workspaces_collider_log_operations_test_externalid string = '/subscriptions/6f1491c1-f8e5-4335-8d95-f2d64080fcf0/resourceGroups/collider-rg-operations-test/providers/microsoft.operationalinsights/workspaces/collider-log-operations-test'
param userAssignedIdentities_ColliderPure_AKS_01_agentpool_externalid string = '/subscriptions/6f1491c1-f8e5-4335-8d95-f2d64080fcf0/resourceGroups/MC_collider-rg-sharedServices-test_ColliderPure-AKS-01_usgovvirginia/providers/Microsoft.ManagedIdentity/userAssignedIdentities/ColliderPure-AKS-01-agentpool'
param workspaces_DefaultWorkspace_6f1491c1_f8e5_4335_8d95_f2d64080fcf0_USGV_externalid string = '/subscriptions/6f1491c1-f8e5-4335-8d95-f2d64080fcf0/resourceGroups/DefaultResourceGroup-USGV/providers/Microsoft.OperationalInsights/workspaces/DefaultWorkspace-6f1491c1-f8e5-4335-8d95-f2d64080fcf0-USGV'
param privateEndpoints_kube_apiserver_externalid string = '/subscriptions/6f1491c1-f8e5-4335-8d95-f2d64080fcf0/resourceGroups/MC_collider-rg-sharedServices-test_ColliderPure-AKS-01_usgovvirginia/providers/Microsoft.Network/privateEndpoints/kube-apiserver'

resource managedClusters_ColliderPure_AKS_01_name_resource 'Microsoft.ContainerService/managedClusters@2025-02-01' = {
  name: managedClusters_ColliderPure_AKS_01_name
  location: 'usgovvirginia'
  tags: {
    CREATED_BY: 'TERRAFORM'
    'arkloud-environment': 'Prod'
    'arkloud-organization': 'Mothership'
    'arkloud-project': 'ms-core'
  }
  sku: {
    name: 'Base'
    tier: 'Free'
  }
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    kubernetesVersion: '1.28.9'
    dnsPrefix: '${managedClusters_ColliderPure_AKS_01_name}-dns'
    agentPoolProfiles: [
      {
        name: 'agentpool'
        count: 1
        vmSize: 'Standard_D4s_v3'
        osDiskSizeGB: 128
        osDiskType: 'Managed'
        kubeletDiskType: 'OS'
        vnetSubnetID: '${virtualNetworks_collider_vnet_sharedServices_test_externalid}/subnets/collider-snet-sharedServices-AKS-SNT-01'
        maxPods: 110
        type: 'VirtualMachineScaleSets'
        maxCount: 9
        minCount: 1
        enableAutoScaling: true
        scaleDownMode: 'Delete'
        powerState: {
          code: 'Running'
        }
        orchestratorVersion: '1.28.9'
        enableNodePublicIP: false
        tags: {
          ARKLOUD_RESOURCE_TRACKING: 'ADMIN'
          CREATED_BY: 'TERRAFORM'
          ZONE: 'PROD'
        }
        nodeTaints: [
          'CriticalAddonsOnly=true:NoSchedule'
        ]
        mode: 'System'
        osType: 'Linux'
        osSKU: 'Ubuntu'
        upgradeSettings: {
          maxSurge: '1'
        }
        enableFIPS: false
        securityProfile: {
          enableVTPM: false
          enableSecureBoot: false
        }
      }
      {
        name: 'userpool'
        count: 5
        vmSize: 'Standard_E4s_v5'
        osDiskSizeGB: 128
        osDiskType: 'Managed'
        kubeletDiskType: 'OS'
        workloadRuntime: 'OCIContainer'
        vnetSubnetID: '${virtualNetworks_collider_vnet_sharedServices_test_externalid}/subnets/collider-snet-sharedServices-AKS-SNT-01'
        maxPods: 250
        type: 'VirtualMachineScaleSets'
        maxCount: 15
        minCount: 1
        enableAutoScaling: true
        scaleDownMode: 'Delete'
        powerState: {
          code: 'Running'
        }
        orchestratorVersion: '1.28.9'
        enableNodePublicIP: false
        mode: 'User'
        enableEncryptionAtHost: false
        enableUltraSSD: false
        osType: 'Linux'
        osSKU: 'Ubuntu'
        upgradeSettings: {
          maxSurge: '1'
          drainTimeoutInMinutes: 1
        }
        enableFIPS: false
        networkProfile: {}
        securityProfile: {
          enableVTPM: false
          enableSecureBoot: false
        }
      }
    ]
    windowsProfile: {
      adminUsername: 'azureuser'
      enableCSIProxy: true
    }
    servicePrincipalProfile: {
      clientId: 'msi'
    }
    addonProfiles: {
      azureKeyvaultSecretsProvider: {
        enabled: true
        config: {
          enableSecretRotation: 'false'
          rotationPollInterval: '2m'
        }
      }
      azurepolicy: {
        enabled: true
      }
      httpApplicationRouting: {
        enabled: false
      }
      omsAgent: {
        enabled: true
        config: {
          logAnalyticsWorkspaceResourceID: workspaces_collider_log_operations_test_externalid
        }
      }
    }
    nodeResourceGroup: 'MC_collider-rg-sharedServices-test_${managedClusters_ColliderPure_AKS_01_name}_usgovvirginia'
    enableRBAC: true
    supportPlan: 'KubernetesOfficial'
    networkProfile: {
      networkPlugin: 'azure'
      networkPolicy: 'azure'
      networkDataplane: 'azure'
      loadBalancerSku: 'Standard'
      loadBalancerProfile: {
        managedOutboundIPs: {
          count: 1
        }
        backendPoolType: 'nodeIPConfiguration'
      }
      serviceCidr: '10.2.0.0/16'
      dnsServiceIP: '10.2.0.10'
      outboundType: 'loadBalancer'
      serviceCidrs: [
        '10.2.0.0/16'
      ]
      ipFamilies: [
        'IPv4'
      ]
    }
    privateLinkResources: [
      {
        id: '${managedClusters_ColliderPure_AKS_01_name_resource.id}/privateLinkResources/management'
        name: 'management'
        type: 'Microsoft.ContainerService/managedClusters/privateLinkResources'
        groupId: 'management'
        requiredMembers: [
          'management'
        ]
      }
    ]
    apiServerAccessProfile: {
      enablePrivateCluster: true
      privateDNSZone: 'system'
      enablePrivateClusterPublicFQDN: true
    }
    identityProfile: {
      kubeletidentity: {
        resourceId: userAssignedIdentities_ColliderPure_AKS_01_agentpool_externalid
        clientId: 'c8b620cf-1b9b-42bd-8638-d8f8492c6553'
        objectId: '4d213c2c-5e4f-4a96-be6a-953e592bdda5'
      }
    }
    autoScalerProfile: {
      'balance-similar-node-groups': 'false'
      'daemonset-eviction-for-empty-nodes': false
      'daemonset-eviction-for-occupied-nodes': true
      expander: 'random'
      'ignore-daemonsets-utilization': false
      'max-empty-bulk-delete': '10'
      'max-graceful-termination-sec': '600'
      'max-node-provision-time': '15m'
      'max-total-unready-percentage': '45'
      'new-pod-scale-up-delay': '0s'
      'ok-total-unready-count': '3'
      'scale-down-delay-after-add': '5m'
      'scale-down-delay-after-delete': '10s'
      'scale-down-delay-after-failure': '3m'
      'scale-down-unneeded-time': '5m'
      'scale-down-unready-time': '20m'
      'scale-down-utilization-threshold': '.5'
      'scan-interval': '10s'
      'skip-nodes-with-local-storage': 'false'
      'skip-nodes-with-system-pods': 'true'
    }
    autoUpgradeProfile: {
      upgradeChannel: 'stable'
    }
    securityProfile: {
      defender: {
        logAnalyticsWorkspaceResourceId: workspaces_DefaultWorkspace_6f1491c1_f8e5_4335_8d95_f2d64080fcf0_USGV_externalid
        securityMonitoring: {
          enabled: true
        }
      }
      customCATrustCertificates: [
        'LS0tLS1CRULS0K'
       ]
    }
    storageProfile: {
      diskCSIDriver: {
        enabled: true
      }
      fileCSIDriver: {
        enabled: true
      }
      snapshotController: {
        enabled: true
      }
    }
    oidcIssuerProfile: {
      enabled: false
    }
    workloadAutoScalerProfile: {}
    azureMonitorProfile: {
      metrics: {
        enabled: true
        kubeStateMetrics: {}
      }
    }
    metricsProfile: {
      costAnalysis: {
        enabled: false
      }
    }
    bootstrapProfile: {
      artifactSource: 'Direct'
    }
  }
}

resource managedClusters_ColliderPure_AKS_01_name_agentpool 'Microsoft.ContainerService/managedClusters/agentPools@2025-02-01' = {
  name: '${managedClusters_ColliderPure_AKS_01_name}/agentpool'
  properties: {
    count: 1
    vmSize: 'Standard_D4s_v3'
    osDiskSizeGB: 128
    osDiskType: 'Managed'
    kubeletDiskType: 'OS'
    vnetSubnetID: '${virtualNetworks_collider_vnet_sharedServices_test_externalid}/subnets/collider-snet-sharedServices-AKS-SNT-01'
    maxPods: 110
    type: 'VirtualMachineScaleSets'
    maxCount: 9
    minCount: 1
    enableAutoScaling: true
    scaleDownMode: 'Delete'
    powerState: {
      code: 'Running'
    }
    orchestratorVersion: '1.28.9'
    enableNodePublicIP: false
    tags: {
      ARKLOUD_RESOURCE_TRACKING: 'ADMIN'
      CREATED_BY: 'TERRAFORM'
      ZONE: 'PROD'
    }
    nodeTaints: [
      'CriticalAddonsOnly=true:NoSchedule'
    ]
    mode: 'System'
    osType: 'Linux'
    osSKU: 'Ubuntu'
    upgradeSettings: {
      maxSurge: '1'
    }
    enableFIPS: false
    securityProfile: {
      enableVTPM: false
      enableSecureBoot: false
    }
  }
  dependsOn: [
    managedClusters_ColliderPure_AKS_01_name_resource
  ]
}

resource managedClusters_ColliderPure_AKS_01_name_userpool 'Microsoft.ContainerService/managedClusters/agentPools@2025-02-01' = {
  name: '${managedClusters_ColliderPure_AKS_01_name}/userpool'
  properties: {
    count: 5
    vmSize: 'Standard_E4s_v5'
    osDiskSizeGB: 128
    osDiskType: 'Managed'
    kubeletDiskType: 'OS'
    workloadRuntime: 'OCIContainer'
    vnetSubnetID: '${virtualNetworks_collider_vnet_sharedServices_test_externalid}/subnets/collider-snet-sharedServices-AKS-SNT-01'
    maxPods: 250
    type: 'VirtualMachineScaleSets'
    maxCount: 15
    minCount: 1
    enableAutoScaling: true
    scaleDownMode: 'Delete'
    powerState: {
      code: 'Running'
    }
    orchestratorVersion: '1.28.9'
    enableNodePublicIP: false
    mode: 'User'
    enableEncryptionAtHost: false
    enableUltraSSD: false
    osType: 'Linux'
    osSKU: 'Ubuntu'
    upgradeSettings: {
      maxSurge: '1'
      drainTimeoutInMinutes: 1
    }
    enableFIPS: false
    networkProfile: {}
    securityProfile: {
      enableVTPM: false
      enableSecureBoot: false
    }
  }
  dependsOn: [
    managedClusters_ColliderPure_AKS_01_name_resource
  ]
}

resource managedClusters_ColliderPure_AKS_01_name_kube_apiserver_3cd95037_5fd1_4f3d_b341_699acc5351a4 'Microsoft.ContainerService/managedClusters/privateEndpointConnections@2025-02-01' = {
  name: '${managedClusters_ColliderPure_AKS_01_name}/kube-apiserver.3cd95037-5fd1-4f3d-b341-699acc5351a4'
  properties: {
    privateEndpoint: {
      id: privateEndpoints_kube_apiserver_externalid
    }
    privateLinkServiceConnectionState: {
      status: 'Approved'
      description: 'Auto Approved'
    }
  }
  dependsOn: [
    managedClusters_ColliderPure_AKS_01_name_resource
  ]
}
