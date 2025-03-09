provider "azurerm" {
  features {
    key_vault {
      purge_soft_delete_on_destroy = true
    }
  }
}

# Define variables
variable "location" {
  default = "East US"
  description = "The Azure region where resources will be created"
}

variable "resource_group_name" {
  default = "example"
  description = "Name of the resource group"
}

variable "admin_username" {
  default = "azureadmin"
  description = "Admin username for VMs"
}

variable "environment" {
  default = "dev"
  description = "Environment (dev, staging, prod)"
}

variable "vnet_address_space" {
  default = ["10.0.0.0/16"]
  description = "Address space for the VNet"
}

variable "subnet_prefixes" {
  default = {
    aks     = "10.0.0.0/20"
    servers = "10.0.16.0/24"
  }
  description = "Subnet prefixes within the VNet"
}

variable "email_address" {
  description = "Email address for Let's Encrypt registration"
  default = "admin@example.com"
}

# Create resource group
resource "azurerm_resource_group" "rg" {
  name     = var.resource_group_name
  location = var.location
}

# Create Key Vault
resource "azurerm_key_vault" "vault" {
  name                        = "${var.resource_group_name}-vault"
  location                    = azurerm_resource_group.rg.location
  resource_group_name         = azurerm_resource_group.rg.name
  enabled_for_disk_encryption = true
  tenant_id                   = data.azurerm_client_config.current.tenant_id
  soft_delete_retention_days  = 7
  purge_protection_enabled    = false

  sku_name = "standard"

  access_policy {
    tenant_id = data.azurerm_client_config.current.tenant_id
    object_id = data.azurerm_client_config.current.object_id

    key_permissions = [
      "Get", "List", "Create", "Delete", "Update", "Recover", "Purge"
    ]

    secret_permissions = [
      "Get", "List", "Set", "Delete", "Recover", "Backup", "Restore", "Purge"
    ]

    certificate_permissions = [
      "Get", "List", "Update", "Create", "Delete", "Recover", "Backup", "Restore", "Purge"
    ]
  }
}

# Get current client configuration
data "azurerm_client_config" "current" {}

# Generate random passwords
resource "random_password" "ansible_password" {
  length           = 16
  special          = true
  override_special = "_%@"
}

resource "random_password" "gitlab_password" {
  length           = 16
  special          = true
  override_special = "_%@"
}

resource "random_password" "gitlab_root_password" {
  length           = 16
  special          = true
  override_special = "_%@"
}

# Store passwords in Key Vault
resource "azurerm_key_vault_secret" "ansible_password" {
  name         = "ansible-password"
  value        = random_password.ansible_password.result
  key_vault_id = azurerm_key_vault.vault.id
}

resource "azurerm_key_vault_secret" "gitlab_password" {
  name         = "gitlab-password"
  value        = random_password.gitlab_password.result
  key_vault_id = azurerm_key_vault.vault.id
}

resource "azurerm_key_vault_secret" "gitlab_root_password" {
  name         = "gitlab-root-password"
  value        = random_password.gitlab_root_password.result
  key_vault_id = azurerm_key_vault.vault.id
}

# Virtual Network and Subnets
resource "azurerm_virtual_network" "vnet" {
  name                = "${var.resource_group_name}-vnet"
  address_space       = var.vnet_address_space
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
}

resource "azurerm_subnet" "servers" {
  name                 = "servers-subnet"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = [var.subnet_prefixes.servers]
}

resource "azurerm_subnet" "aks" {
  name                 = "aks-subnet"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = [var.subnet_prefixes.aks]
}

# Network Security Group for servers
resource "azurerm_network_security_group" "servers_nsg" {
  name                = "servers-nsg"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  security_rule {
    name                       = "SSH"
    priority                   = 1001
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "HTTP"
    priority                   = 1002
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "80"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "HTTPS"
    priority                   = 1003
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "443"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

# Associate NSG with server subnet
resource "azurerm_subnet_network_security_group_association" "servers_nsg_assoc" {
  subnet_id                 = azurerm_subnet.servers.id
  network_security_group_id = azurerm_network_security_group.servers_nsg.id
}

# Public IPs
resource "azurerm_public_ip" "ansible_ip" {
  name                = "ansible-public-ip"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  allocation_method   = "Static"
  domain_name_label   = "${var.resource_group_name}-ansible"
}

resource "azurerm_public_ip" "gitlab_ip" {
  name                = "gitlab-public-ip"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  allocation_method   = "Static"
  domain_name_label   = "${var.resource_group_name}-gitlab"
}

# Network Interfaces
resource "azurerm_network_interface" "ansible_nic" {
  name                = "ansible-nic"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.servers.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.ansible_ip.id
  }
}

resource "azurerm_network_interface" "gitlab_nic" {
  name                = "gitlab-nic"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.servers.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.gitlab_ip.id
  }
}

# Ansible Server VM
resource "azurerm_linux_virtual_machine" "ansible" {
  name                = "ansible-server"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  size                = "Standard_D2s_v3"
  admin_username      = var.admin_username
  network_interface_ids = [
    azurerm_network_interface.ansible_nic.id,
  ]

  admin_password                  = azurerm_key_vault_secret.ansible_password.value
  disable_password_authentication = false

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Premium_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }

  custom_data = base64encode(<<-EOF
    #!/bin/bash
    apt-get update
    apt-get install -y software-properties-common
    apt-add-repository --yes --update ppa:ansible/ansible
    apt-get install -y ansible
    EOF
  )

  tags = {
    environment = var.environment
  }
}

# GitLab CE Server VM
resource "azurerm_linux_virtual_machine" "gitlab" {
  name                = "gitlab-server"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  size                = "Standard_D4s_v3"
  admin_username      = var.admin_username
  network_interface_ids = [
    azurerm_network_interface.gitlab_nic.id,
  ]

  admin_password                  = azurerm_key_vault_secret.gitlab_password.value
  disable_password_authentication = false

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Premium_LRS"
    disk_size_gb         = 100
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }

  custom_data = base64encode(<<-EOF
    #!/bin/bash
    apt-get update
    apt-get install -y curl openssh-server ca-certificates tzdata perl
    
    # Add GitLab package repository
    curl https://packages.gitlab.com/install/repositories/gitlab/gitlab-ce/script.deb.sh | bash
    
    # Install GitLab CE
    EXTERNAL_URL="https://${azurerm_public_ip.gitlab_ip.fqdn}" \
    GITLAB_ROOT_PASSWORD="${azurerm_key_vault_secret.gitlab_root_password.value}" \
    apt-get install -y gitlab-ce
    
    # Configure GitLab
    gitlab-ctl reconfigure
    EOF
  )

  tags = {
    environment = var.environment
  }
}

# AKS Cluster
resource "azurerm_kubernetes_cluster" "aks" {
  name                = "${var.resource_group_name}-aks"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  dns_prefix          = "${var.resource_group_name}-aks"
  kubernetes_version  = "1.25.6"

  default_node_pool {
    name                = "default"
    node_count          = 1
    vm_size             = "Standard_D2s_v3"
    vnet_subnet_id      = azurerm_subnet.aks.id
    enable_auto_scaling = true
    min_count           = 1
    max_count           = 10
  }

  network_profile {
    network_plugin     = "azure"
    dns_service_ip     = "10.0.64.10"
    service_cidr       = "10.0.64.0/19"
    docker_bridge_cidr = "172.17.0.1/16"
  }

  identity {
    type = "SystemAssigned"
  }

  key_vault_secrets_provider {
    secret_rotation_enabled = true
  }

  tags = {
    environment = var.environment
  }
}

# Assign Key Vault access to AKS managed identity
resource "azurerm_key_vault_access_policy" "aks" {
  key_vault_id = azurerm_key_vault.vault.id
  tenant_id    = azurerm_kubernetes_cluster.aks.identity[0].tenant_id
  object_id    = azurerm_kubernetes_cluster.aks.identity[0].principal_id

  secret_permissions = [
    "Get", "List"
  ]
}

# Helm provider for installing cert-manager and other tools
provider "helm" {
  kubernetes {
    host                   = azurerm_kubernetes_cluster.aks.kube_config.0.host
    client_certificate     = base64decode(azurerm_kubernetes_cluster.aks.kube_config.0.client_certificate)
    client_key             = base64decode(azurerm_kubernetes_cluster.aks.kube_config.0.client_key)
    cluster_ca_certificate = base64decode(azurerm_kubernetes_cluster.aks.kube_config.0.cluster_ca_certificate)
  }
}

# Install cert-manager
resource "helm_release" "cert_manager" {
  name       = "cert-manager"
  repository = "https://charts.jetstack.io"
  chart      = "cert-manager"
  namespace  = "cert-manager"
  version    = "v1.11.0"
  create_namespace = true

  set {
    name  = "installCRDs"
    value = "true"
  }

  depends_on = [azurerm_kubernetes_cluster.aks]
}

# Create Let's Encrypt ClusterIssuer
resource "kubernetes_manifest" "cluster_issuer" {
  manifest = {
    apiVersion = "cert-manager.io/v1"
    kind       = "ClusterIssuer"
    metadata = {
      name = "letsencrypt-prod"
    }
    spec = {
      acme = {
        server = "https://acme-v02.api.letsencrypt.org/directory"
        email  = var.email_address
        privateKeySecretRef = {
          name = "letsencrypt-prod"
        }
        solvers = [
          {
            http01 = {
              ingress = {
                class = "nginx"
              }
            }
          }
        ]
      }
    }
  }

  depends_on = [helm_release.cert_manager]
}

# Install NGINX Ingress Controller
resource "helm_release" "nginx_ingress" {
  name       = "nginx-ingress"
  repository = "https://kubernetes.github.io/ingress-nginx"
  chart      = "ingress-nginx"
  namespace  = "ingress-nginx"
  create_namespace = true

  set {
    name  = "controller.service.annotations.service\\.beta\\.kubernetes\\.io/azure-load-balancer-health-probe-request-path"
    value = "/healthz"
  }

  depends_on = [azurerm_kubernetes_cluster.aks]
}

# Output values
output "ansible_server_public_ip" {
  value = azurerm_public_ip.ansible_ip.ip_address
}

output "ansible_server_fqdn" {
  value = azurerm_public_ip.ansible_ip.fqdn
}

output "gitlab_server_public_ip" {
  value = azurerm_public_ip.gitlab_ip.ip_address
}

output "gitlab_server_fqdn" {
  value = azurerm_public_ip.gitlab_ip.fqdn
}

output "aks_cluster_name" {
  value = azurerm_kubernetes_cluster.aks.name
}

output "kube_config" {
  value     = azurerm_kubernetes_cluster.aks.kube_config_raw
  sensitive = true
}

output "key_vault_name" {
  value = azurerm_key_vault.vault.name
}

output "resource_group_name" {
  value = azurerm_resource_group.rg.name
}
