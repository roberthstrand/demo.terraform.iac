terraform {
  backend "azurerm" {
    resource_group_name  = "demo-services-rg"
    storage_account_name = "rsterraformdemo"
    container_name       = "tfstate"
    key                  = "tf.state"
  }
}