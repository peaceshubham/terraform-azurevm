terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=3.23.0"
    }
  }
}

###RESOURCE-GROUP

resource "azurerm_resource_group" "rg" {
  name     = var.resource_group
  location = var.location
}

###VNET

resource "azurerm_virtual_network" "rg" {
  name                = "${var.prefix}-vnet"
  address_space       = ["${var.address_space}"]
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
}

###SUBNET

resource "azurerm_subnet" "rg" {
  name                 = "${var.prefix}-subnet"
  virtual_network_name = azurerm_virtual_network.rg.name
  resource_group_name  = azurerm_resource_group.rg.name
  address_prefixes     = ["${var.subnet_prefix}"]
}

###PUBLIC-IP

resource "azurerm_public_ip" "rg" {
  name                = "${var.prefix}-pubip"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  allocation_method   = "Static"
}

resource "azurerm_network_security_group" "rg" {
  name                = "${var.prefix}-sg"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  security_rule {
    name                       = "SSH-http"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_ranges    = ["22", "80", "443"]
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

}
###NIC

resource "azurerm_network_interface" "rg" {
  name                = "${var.prefix}-nic"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  ip_configuration {
    name                          = "internal-ip"
    subnet_id                     = azurerm_subnet.rg.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.rg.id
  }
}

resource "tls_private_key" "sshkey" {
  algorithm = "RSA"
  rsa_bits  = "2048"
}

resource "local_file" "private" {
  content  = tls_private_key.sshkey.private_key_pem
  filename = "id_rsa"
}


resource "azurerm_virtual_machine" "vm" {
  name                  = "${var.prefix}-vm"
  location              = azurerm_resource_group.rg.location
  resource_group_name   = azurerm_resource_group.rg.name
  network_interface_ids = [azurerm_network_interface.rg.id]
  vm_size               = "Standard_B2s"
  delete_os_disk_on_termination = true
  storage_image_reference {
    offer     = var.offer
    publisher = var.publisher
    sku       = var.sku
    version   = var.os_ver
  }

  storage_os_disk {
    name              = "${var.prefix}-vm-osdisk"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }

  os_profile {
    computer_name  = "${var.prefix}-hostvm"
    admin_username = var.vm_username

  }
  os_profile_linux_config {
    disable_password_authentication = true
    ssh_keys {
      path     = "/home/${var.vm_username}/.ssh/authorized_keys"
      key_data = tls_private_key.sshkey.public_key_openssh
    }
  }
}


