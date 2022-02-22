terraform {
  backend "azurerm" {
    resource_group_name  = "jalex-storage-rg"
    storage_account_name = "jalexstorage92831"
    container_name       = "jalex-blob"
    key                  = "appservice"
  }
}
