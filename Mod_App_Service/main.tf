data "azurerm_resource_group" "rg" {
  name = var.resource_group
}

# Create app service plan
resource "azurerm_app_service_plan" "service_plan" {
  name = var.app_service_plan_name
  location = data.azurerm_resource_group.rg.location
  resource_group_name = data.azurerm_resource_group.rg.name
  kind = "Linux"
  reserved = true
  sku {
    tier = var.AS_Sku_Tier
    size = var.AS_Sku_Size
  }
  tags = {
    environment = "dev"
  }
  depends_on = [
    azurerm_resource_group.rg
  ]
}

data "azurerm_app_service_plan" "app" {
  name                = azurerm_app_service_plan.service_plan.name
  resource_group_name = data.azurerm_resource_group.rg.name
  depends_on = [
    azurerm_app_service_plan.service_plan
  ]
}

# Create JAVA app service
resource "azurerm_app_service" "app_service" {
  name = var.app_service_name
  location = data.azurerm_resource_group.rg.location
  resource_group_name = data.azurerm_resource_group.rg.name
  app_service_plan_id = data.azurerm_app_service_plan.app.id

  site_config {
      linux_fx_version = "TOMCAT|8.5-java11"
    }
  tags = {
      environment = "dev"
    }
  }


