terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "2.95.0"
    }
  }
}

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "rg" {
  count = length(var.app-service.key.NAME)
  name = "${var.team}-${var.app-service.key.NAME[count.index]}-RG"
  location = var.app-service.key.LOCATION[count.index]
}

# Create app service plan
resource "azurerm_app_service_plan" "service_plan" {
  count = length(var.app-service.key.NAME)
  name = "${var.team}-${var.app-service.key.NAME[count.index]}-plan"
  location = var.app-service.key.LOCATION[count.index]
  resource_group_name = "${var.team}-${var.app-service.key.NAME[count.index]}-RG"
  kind = "Linux"
  reserved = true
  sku {
    tier = var.app-sku.key.TIER[count.index]
    size = var.app-sku.key.SIZE[count.index]
  }
  tags = {
    environment = "dev"
  }
  depends_on = [
    azurerm_resource_group.rg
  ]
}

data "azurerm_app_service_plan" "app1" {
  name                = "${var.team}-${var.app-service.key.NAME[0]}-plan"
  resource_group_name = "${var.team}-${var.app-service.key.NAME[0]}-RG"
  depends_on = [
    azurerm_app_service_plan.service_plan
  ]
}
data "azurerm_app_service_plan" "app2" {
  name                = "${var.team}-${var.app-service.key.NAME[1]}-plan"
  resource_group_name = "${var.team}-${var.app-service.key.NAME[1]}-RG"
  depends_on = [
    azurerm_app_service_plan.service_plan
  ]
}


# Create JAVA app service
resource "azurerm_app_service" "app_service1" {
  name = "${var.team}-${var.app-service.key.NAME[0]}-SVC"
  location = var.app-service.key.LOCATION[0]
  resource_group_name = "${var.team}-${var.app-service.key.NAME[0]}-RG"
  app_service_plan_id = data.azurerm_app_service_plan.app1.id

  site_config {
      linux_fx_version = "TOMCAT|8.5-java11"
    }
  source_control {
    repo_url = "https://github.com/bdgomey/skillstorm-movies.git"
    branch = "master"
    manual_integration = true
    use_mercurial = false
  }
  tags = {
      environment = "dev"
    }
  }

  resource "azurerm_app_service" "app_service2" {
  name = "${var.team}-${var.app-service.key.NAME[1]}-SVC"
  location = var.app-service.key.LOCATION[1]
  resource_group_name = "${var.team}-${var.app-service.key.NAME[1]}-RG"
  app_service_plan_id = data.azurerm_app_service_plan.app2.id

  site_config {
      linux_fx_version = "TOMCAT|8.5-java11"
    }
  source_control {
    repo_url = "https://github.com/bdgomey/skillstorm-movies.git"
    branch = "master"
    manual_integration = true
    use_mercurial = false
  }
  tags = {
      environment = "dev"
    }
  }

