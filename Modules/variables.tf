variable "resource_group" {
  default = "terra-vm"
}

variable "location" {
  default = "eastus"
}

variable "prefix" {
  default = "tfvm"
}

###VNET

variable "address_space" {
  default = "10.0.0.0/16"
}

variable "subnet_prefix" {
  default = "10.0.1.0/24"
}

#VM
variable "vm_username" {
  default = "ubuntu"
}


variable "offer" {
  default = "0001-com-ubuntu-server-focal"
}
variable "publisher" {
  default = "Canonical"
}
variable "sku" {
  default = "20_04-lts-gen2"
}
variable "os_ver" {
  default = "latest"
}