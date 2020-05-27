# Define the provider as Azure
terraform {
    required_providers {
        azurerm = "~> 1.34"
    }
}
# Create resource group for our demo
resource "azurerm_resource_group" "terraform" {
    name     = "${var.deployname}-rg"
<<<<<<< HEAD
    location = var.location-eu
}
# Creating our container groups,
# first one in EU...
resource "azurerm_container_group" "eu" {
    # Container group argument
    name                = "cont-${var.deployname}-eu"
    location            = var.location-eu
    resource_group_name = azurerm_resource_group.terraform.name
    ip_address_type     = "public"
    os_type             = "Linux"
    # The container itself
    container {
        name   = "web-${var.deployname}"
        image  = "nginx:latest"
        cpu    = "1"
        memory = "0.5"
        ports {
            port     = 80
            protocol = "TCP"
        }
    }
}
# ...and the second one in the US
resource "azurerm_container_group" "us" {
    # Container group argument
    name                = "cont-${var.deployname}-us"
    location            = var.location-us
    resource_group_name = azurerm_resource_group.terraform.name
    ip_address_type     = "public"
    os_type             = "Linux"
    # The container itself
    container {
        name   = "web-${var.deployname}"
        image  = "nginx:latest"
        cpu    = "1"
        memory = "0.5"
        ports {
            port     = 80
            protocol = "TCP"
        }
    }
}
# Azure Traffic Manager, profile
resource "azurerm_traffic_manager_profile" "terraform" {
    name                    = "tm-profile-${var.deployname}"
    resource_group_name     = azurerm_resource_group.terraform.name
    traffic_routing_method  = "Geographic"
    dns_config {
        relative_name       = "tm-${var.deployname}-dns"
        ttl                 = 100
    }
    monitor_config {
        protocol            = "http"
        port                = 80
        path                = "/"
    }
}
# Azure Traffic Manager, endpoint in Azure
resource "azurerm_traffic_manager_endpoint" "eu" {
    name                = "tm-${var.deployname}-endpoint-eu"
    resource_group_name = azurerm_resource_group.terraform.name
    profile_name        = azurerm_traffic_manager_profile.terraform.name
    type                = "externalEndpoints"
    target              = azurerm_container_group.eu.ip_address
    geo_mappings        = ["geo-eu"]
    weight              = 100
}
resource "azurerm_traffic_manager_endpoint" "us" {
    name                = "tm-${var.deployname}-endpoint-us"
    resource_group_name = azurerm_resource_group.terraform.name
    profile_name        = azurerm_traffic_manager_profile.terraform.name
    type                = "externalEndpoints"
    target              = azurerm_container_group.us.ip_address
    geo_mappings        = ["us"]
    weight              = 100
}
# Creating a new CNAME-record that our traffic manager will be using
resource "azurerm_dns_cname_record" "terraform" {
    name                = "uit"
    zone_name           = "terraform.skyarkitektur.no"
    resource_group_name = "demo"
    ttl                 = 300
    record              = azurerm_traffic_manager_profile.terraform.fqdn
=======
    location = var.location
}

resource "azurerm_network_security_group" "terraform" {
  name                = "${var.deployname}-nsg"
  location            = azurerm_resource_group.terraform.location
  resource_group_name = azurerm_resource_group.terraform.name
}

resource "azurerm_virtual_network" "terraform" {
  name                = "${var.deployname}-vnet"
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

  tags = var.tags
>>>>>>> eba9404386c2d3ab874cd22c3d35658985f51dcf
}