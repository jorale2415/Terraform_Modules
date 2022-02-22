terraform {
  required_version = ">= 1.1.5"
}
resource "azurerm_virtual_network" "example" {
  name                = var.vnet_name
  location            = var.vnet_location
  resource_group_name = var.vnet_rg_name
  address_space       = var.vnet_address_space
  dns_servers         = var.vnet_dns_servers
}
resource "azurerm_subnet" "MyResource" {
   count = var.number_of_subnets
   name = "subnet-${count.index + 1}"
   resource_group_name = var.vnet_rg_name
   virtual_network_name = var.vnet_name
   address_prefix = cidrsubnet(element(var.vnet_address_space,0), 8, "${count.index}")
   depends_on = [
     azurerm_virtual_network.example
   ]
}
