terraform {
  required_version = ">= 1.1.5"
}

data "azurerm_resource_group" "primary_rg" {
  name = var.resource_group1
}
data "azurerm_resource_group" "secondary_rg" {
  name = var.resource_group2
}
data "azurerm_resource_group" "traffic_rg" {
  name = var.resource_group3
}

data "azurerm_app_service" "app1" {
  name                = var.app1_service_name
  resource_group_name = data.azurerm_resource_group.primary_rg.name
}
data "azurerm_app_service" "app2" {
  name                = var.app2_service_name
  resource_group_name = data.azurerm_resource_group.secondary_rg.name
}

resource "azurerm_traffic_manager_profile" "my_traffic_mgr_profile" {
  name                = var.Traffic_Manager_Profile_Name
  resource_group_name = data.azurerm_resource_group.traffic_rg.name

  traffic_routing_method = var.traffic_routing_method

  dns_config {
    relative_name = var.Dns_Config_Name
    ttl           = 100
  }

  monitor_config {
    protocol                     = var.protocol
    port                         = var.port
    path                         = "/"
    interval_in_seconds          = var.interval_in_seconds
    timeout_in_seconds           = var.timeout_in_seconds
    tolerated_number_of_failures = var.tolerated_number_of_failures
  }
}

resource "azurerm_traffic_manager_azure_endpoint" "Primary_Endpoint" {
  name               = "${var.team}-Primary-Endpoint"
  profile_id         = azurerm_traffic_manager_profile.my_traffic_mgr_profile.id
  weight             = 100
  priority           = 1
  target_resource_id = data.azurerm_app_service.app1.id
}

resource "azurerm_traffic_manager_azure_endpoint" "Secondary_Endpoint" {
  name               = "${var.team}-Secondary-Endpoint"
  profile_id         = azurerm_traffic_manager_profile.my_traffic_mgr_profile.id
  weight             = 100
  priority           = 2
  target_resource_id = data.azurerm_app_service.app2.id
}