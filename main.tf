# Define the provider as Azure
provider "azurerm" {
  version = "=2.51.0"
  features {}
}
# Create resource group for our demo
resource "azurerm_resource_group" "terraform" {
    name     = format("%s-rg", var.deployname)
    location = var.location
}

resource "azurerm_network_security_group" "terraform" {
  name                = format("%s-nsg", var.deployname)
  location            = azurerm_resource_group.terraform.location
  resource_group_name = azurerm_resource_group.terraform.name
}

resource "azurerm_virtual_network" "terraform" {
  name                = format("%s-vnet", var.deployname)
  location            = azurerm_resource_group.terraform.location
  resource_group_name = azurerm_resource_group.terraform.name
  address_space       = ["10.0.0.0/16"]
  subnet {
    name           = "subnet1"
    address_prefix = "10.0.1.0/24"
  }

  subnet {
    name           = "subnet2"
    address_prefix = "10.0.2.0/24"
    security_group = azurerm_network_security_group.terraform.id
  }

  subnet {
    name           = "subnet2"
    address_prefix = "10.0.2.0/24"
    security_group = azurerm_network_security_group.terraform.id
  }

  tags = var.tags
}