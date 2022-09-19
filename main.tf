terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=3.23.0"
    }
  }
}

module "linux-vm" {
  source         = "./Modules"
  resource_group = "vmrg"
  location       = "East US"
  prefix         = "test"
  #  address_space = ""
  #  subnet_prefix = ""
  vm_username = "myuser"
  #  offer = ""
  #  publisher = ""
  #  sku = ""
  #  os_ver = ""

}