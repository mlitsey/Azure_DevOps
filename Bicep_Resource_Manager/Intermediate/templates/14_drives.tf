terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.110"
    }
  }
}

provider "azurerm" {
  features {}
}

# -------------------------
# Variables (params)
# -------------------------
variable "name" {
  description = "Base name for all resources"
  type        = string
  default     = "dsk-test"
}

variable "host_name" {
  description = "Hostname for VM"
  type        = string
  default     = "testvm"
}

variable "location" {
  description = "Location for resources"
  type        = string
  default     = "eastus"
}

variable "subnet_id" {
  description = "Existing subnet resource ID"
  type        = string
}

variable "create_public_ip" {
  description = "Create a public IP?"
  type        = bool
  default     = true
}

variable "admin_username" {
  description = "Admin username"
  type        = string
  default     = "azureuser"
}

variable "admin_password" {
  description = "Admin password"
  type        = string
  sensitive   = true
}

variable "admin_ssh_public_key" {
  description = "SSH public key"
  type        = string
}

variable "vm_size" {
  description = "VM size"
  type        = string
  default     = "Standard_D8s_v6"
}

variable "disk_count" {
  description = "How many data disks to attach"
  type        = number
  default     = 16
}

variable "disk_size_gib" {
  description = "Size of each data disk in GiB"
  type        = number
  default     = 4
}

variable "data_disk_sku" {
  description = "Disk SKU (PremiumV2_LRS = NVMe)"
  type        = string
  default     = "PremiumV2_LRS"
}

variable "ultra_ssd_enabled" {
  description = "Enable Ultra SSD capability"
  type        = bool
  default     = false
}

# -------------------------
# Networking
# -------------------------
resource "azurerm_public_ip" "pip" {
  count               = var.create_public_ip ? 1 : 0
  name                = "${var.name}-pip"
  location            = var.location
  resource_group_name = azurerm_resource_group.rg.name
  allocation_method   = "Static"
  sku                 = "Standard"
}

resource "azurerm_network_interface" "nic" {
  name                = "${var.name}-nic"
  location            = var.location
  resource_group_name = azurerm_resource_group.rg.name

  enable_accelerated_networking = true

  ip_configuration {
    name                          = "ipconfig1"
    subnet_id                     = var.subnet_id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = var.create_public_ip ? azurerm_public_ip.pip[0].id : null
  }
}

# -------------------------
# Data Disks
# -------------------------
resource "azurerm_managed_disk" "data" {
  count                = var.disk_count
  name                 = "${var.name}-data-${count.index + 2}"
  location             = var.location
  resource_group_name  = azurerm_resource_group.rg.name
  storage_account_type = var.data_disk_sku
  create_option        = "Empty"
  disk_size_gb         = var.disk_size_gib
  zone                 = "1"
}

# -------------------------
# VM
# -------------------------
resource "azurerm_linux_virtual_machine" "vm" {
  name                = var.name
  location            = var.location
  resource_group_name = azurerm_resource_group.rg.name
  size                = var.vm_size
  admin_username      = var.admin_username
  admin_password      = var.admin_password

  network_interface_ids = [
    azurerm_network_interface.nic.id
  ]

  zone = "1"

  admin_ssh_key {
    username   = var.admin_username
    public_key = var.admin_ssh_public_key
  }

  source_image_reference {
    publisher = "RedHat"
    offer     = "RHEL"
    sku       = "9-lvm-gen2"
    version   = "latest"
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Premium_LRS"
    disk_size_gb         = 64
  }

  dynamic "data_disk" {
    for_each = azurerm_managed_disk.data
    content {
      lun               = data_disk.key + 2
      managed_disk_id   = data_disk.value.id
      caching           = "None"
      storage_account_type = var.data_disk_sku
    }
  }

  additional_capabilities {
    ultra_ssd_enabled = var.ultra_ssd_enabled
  }

  disk_controller_type = "NVMe"
}

# -------------------------
# Outputs
# -------------------------
output "vm_id" {
  value = azurerm_linux_virtual_machine.vm.id
}

output "vm_private_ip" {
  value = azurerm_network_interface.nic.private_ip_address
}

output "public_ip" {
  value = var.create_public_ip ? azurerm_public_ip.pip[0].ip_address : "none"
}
