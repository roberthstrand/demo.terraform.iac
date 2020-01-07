# Define the provider as Azure
terraform {
    required_providers {
        azurerm = "~> 1.34"
    }
}
# Create resource group for our demo
resource "azurerm_resource_group" "terraform" {
    name     = "rg-${var.deployname}"
    location = "${var.location-eu}"
}
# Creating our container groups,
# first one in EU...
resource "azurerm_container_group" "eu" {
    # Container group argument
    name                = "cont-${var.deployname}-eu"
    location            = "${var.location-eu}"
    resource_group_name = "${azurerm_resource_group.terraform.name}"
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
    location            = "${var.location-us}"
    resource_group_name = "${azurerm_resource_group.terraform.name}"
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
    resource_group_name     = "${azurerm_resource_group.terraform.name}"
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
resource "azurerm_traffic_manager_endpoint" "eu2" {
    name                = "tm-${var.deployname}-endpoint-eu"
    resource_group_name = "${azurerm_resource_group.terraform.name}"
    profile_name        = "${azurerm_traffic_manager_profile.terraform.name}"
    type                = "externalEndpoints"
    target              = "${azurerm_container_group.eu.ip_address}"
    geo_mappings        = ["geo-eu"]
    weight              = 100
}
resource "azurerm_traffic_manager_endpoint" "us" {
    name                = "tm-${var.deployname}-endpoint-us"
    resource_group_name = "${azurerm_resource_group.terraform.name}"
    profile_name        = "${azurerm_traffic_manager_profile.terraform.name}"
    type                = "externalEndpoints"
    target              = "${azurerm_container_group.us.ip_address}"
    geo_mappings        = ["us"]
    weight              = 100
}
# Creating a new CNAME-record that our traffic manager will be using
resource "azurerm_dns_cname_record" "terraform" {
    name                = "uit"
    zone_name           = "terraform.skyarkitektur.no"
    resource_group_name = "demo"
    ttl                 = 300
    record              = "${azurerm_traffic_manager_profile.terraform.fqdn}"
}