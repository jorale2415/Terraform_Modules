terraform {
  required_version = ">= 1.1.5"
}

data "azurerm_resource_group" "rg1" {
  name = "${var.team}-${var.region1}-rg"
}
data "azurerm_resource_group" "rg2" {
  name = "${var.team}-${var.region2}-rg"
}
data "azurerm_virtual_network" "primary_vnet" {
  name = "${var.team}-${var.region1}-primary-vnet"
  resource_group_name = data.azurerm_resource_group.rg1.name
}
data "azurerm_virtual_network" "secondary_vnet" {
  name = "${var.team}-${var.region2}-secondary-vnet"
  resource_group_name = data.azurerm_resource_group.rg2.name
}

resource "azurerm_virtual_network_peering" "Primary_vnet_Peered_Secondary_vnet" {
   name = "${var.team}-${var.region1}-peered-${var.region2}"
   resource_group_name = data.azurerm_resource_group.rg1.name
   virtual_network_name = data.azurerm_virtual_network.primary_vnet.name
   remote_virtual_network_id = data.azurerm_virtual_network.secondary_vnet.id
}
resource "azurerm_virtual_network_peering" "Secondary_vnet_Peered_Primary_vnet" {
   name = "${var.team}-${var.region2}-peered-${var.region1}"
   resource_group_name = data.azurerm_resource_group.rg2.name
   virtual_network_name = data.azurerm_virtual_network.secondary_vnet.name
   remote_virtual_network_id = data.azurerm_virtual_network.primary_vnet.id
}