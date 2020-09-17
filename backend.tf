terraform {
  backend "azurerm" {
    resource_group_name  = "demo-services-rg"
    storage_account_name = "rsterraformdemo"
    container_name       = "tfstate"
    key                  = "tf.state"
    use_msi              = true
    subscription_id      = "7e6ecd0c-3d73-49d9-b57f-f90f1dc701fb"
    tenant_id            = "8f47ad71-44ca-48bf-afe3-56b9360a4495"
  }
}