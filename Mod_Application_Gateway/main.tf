data "azurerm_resource_group" "rg" {
  name = var.resource_group
}
data "azurerm_virtual_network" "vnet" {
  name = var.vnet
  resource_group_name = var.resource_group
}
data "azurerm_subnet" "subnet" {
  name                 = var.subnet_name
  virtual_network_name = var.vnet
  resource_group_name  = var.resource_group
}
data "azurerm_app_service" "app_service" {
  name                = var.app_service_name
  resource_group_name = var.resource_group
}

resource "azurerm_public_ip" "pip" {
  name                = "${var.team}application-gateway-pip"
  resource_group_name = data.azurerm_resource_group.rg.name
  location            = data.azurerm_resource_group.rg.location
  allocation_method   = "Dynamic"
}

#&nbsp;since these variables are re-used - a locals block makes this more maintainable
locals {
  backend_address_pool_name      = "${data.azurerm_virtual_network.vnet.name}-beap"
  frontend_port_name             = "${data.azurerm_virtual_network.vnet.name}-feport"
  frontend_ip_configuration_name = "${data.azurerm_virtual_network.vnet.name}-feip"
  http_setting_name              = "${data.azurerm_virtual_network.vnet.name}-be-htst"
  listener_name                  = "${data.azurerm_virtual_network.vnet.name}-httplstn"
  request_routing_rule_name      = "${data.azurerm_virtual_network.vnet.name}-rqrt"
  redirect_configuration_name    = "${data.azurerm_virtual_network.vnet.name}-rdrcfg"
}

resource "azurerm_application_gateway" "network" {
  name                = "${var.team}-appgateway"
  resource_group_name = data.azurerm_resource_group.rg.name
  location            = data.azurerm_resource_group.rg.location

  sku {
    name     = "Standard_Small"
    tier     = "Standard"
    capacity = 2
  }

  gateway_ip_configuration {
    name      = "${var.team}-gateway-ip-configuration"
    subnet_id = data.azurerm_subnet.subnet.id
  }

  frontend_port {
    name = local.frontend_port_name
    port = 80
  }

  frontend_ip_configuration {
    name                 = local.frontend_ip_configuration_name
    public_ip_address_id = azurerm_public_ip.pip.id
  }

  backend_address_pool {
    name = local.backend_address_pool_name
    fqdns = ["${var.app_service_name}"]
  }

  backend_http_settings {
    name                  = local.http_setting_name
    cookie_based_affinity = "Disabled"
    path                  = "/path1/"
    port                  = 80
    protocol              = "Http"
    request_timeout       = 60
    pick_host_name_from_backend_address = true
  }
 
  http_listener {
    name                           = local.listener_name
    frontend_ip_configuration_name = local.frontend_ip_configuration_name
    frontend_port_name             = local.frontend_port_name
    protocol                       = "Http"
  }

  request_routing_rule {
    name                       = local.request_routing_rule_name
    rule_type                  = "Basic"
    http_listener_name         = local.listener_name
    backend_address_pool_name  = local.backend_address_pool_name
    backend_http_settings_name = local.http_setting_name
  }
}
 