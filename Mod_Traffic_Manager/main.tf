terraform {
  required_version = ">= 1.1.5"
}


data "azurerm_public_ip" "rg1_external_pip" {
  name = "${var.team}-${var.region1}-ExternalLoadBalancer-PIP"
  resource_group_name = data.azurerm_resource_group.rg1.name
}
data "azurerm_public_ip" "rg2_external_pip" {
  name = "${var.team}-${var.region2}-ExternalLoadBalancer-PIP"
  resource_group_name = data.azurerm_resource_group.rg2.name    
}
data "azurerm_resource_group" "rg1" {
  name = "${var.team}-${var.region1}-rg"
}
data "azurerm_resource_group" "rg2" {
  name = "${var.team}-${var.region2}-rg"
}
data "azurerm_resource_group" "traffic_rg" {
  name = "${var.team}-${var.traffic_mgr}-rg"
}

resource "azurerm_traffic_manager_profile" "my_traffic_mgr_profile" {
  name                = "${var.team}-${var.traffic_mgr}"
  resource_group_name = data.azurerm_resource_group.traffic_rg.name

  traffic_routing_method = "Priority"

  dns_config {
    relative_name = "${var.team}-${var.traffic_mgr}"
    ttl           = 100
  }

  monitor_config {
    protocol                     = "http"
    port                         = 80
    path                         = "/"
    interval_in_seconds          = 30
    timeout_in_seconds           = 9
    tolerated_number_of_failures = 3
  }
}

resource "azurerm_traffic_manager_azure_endpoint" "rg1_external_endpoint" {
  name               = "${var.team}-${var.region1}-external-endpoint"
  profile_id         = azurerm_traffic_manager_profile.my_traffic_mgr_profile.id
  weight             = 100
  priority           = 1
  target_resource_id = data.azurerm_public_ip.rg1_external_pip.id
}

resource "azurerm_traffic_manager_azure_endpoint" "rg2_external_endpoint" {
  name               = "${var.team}-${var.region2}-external-endpoint"
  profile_id         = azurerm_traffic_manager_profile.my_traffic_mgr_profile.id
  weight             = 100
  priority           = 2
  target_resource_id = data.azurerm_public_ip.rg2_external_pip.id
}