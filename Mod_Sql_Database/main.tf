/*
resource "azurerm_resource_group" "rg" {
  name     = var.rg1
  location = var.resource_group_location
}
resource "azurerm_resource_group" "rg2" {
  name     = var.rg2
  location = var.resource_group_location2
}
*/
resource "random_string" "random" {
  length           = 6
  special          = true
  override_special = "/@£$"
}
data "azurerm_resource_group" "rg" {
  name = var.primary_resource_group_name
}
data "azurerm_resource_group" "rg2" {
  name = var.secondary_resource_group_name
}

data "azurerm_key_vault" "existing" {
  name                = var.key_vault
  resource_group_name = var.key_vault_rg
}
data "azurerm_key_vault_secret" "username" {
  name         = var.secret_username
  key_vault_id = data.azurerm_key_vault.existing.id
}
data "azurerm_key_vault_secret" "password" {
  name         = var.secret_password
  key_vault_id = data.azurerm_key_vault.existing.id
}


resource "azurerm_app_service_plan" "my_app_service_plan" {
  name                = "${var.team}-app-service-plan"
  location            = data.azurerm_resource_group.rg.location
  resource_group_name = data.azurerm_resource_group.rg.name

  sku {
    tier = var.asp_sku
    size = var.asp_tier
  }
}

resource "azurerm_app_service_plan" "my_app_service_plan2" {
  name                = "${var.team}-app-service-plan2-${random_string.random.result}"
  location            = data.azurerm_resource_group.rg2.location
  resource_group_name = data.azurerm_resource_group.rg

  sku {
    tier = var.asp_sku
    size = var.asp_tier
  }
}

resource "azurerm_app_service" "my_app_service" {
  name                = "${var.team}-app-service-${random_string.random.result}"
  location            = data.azurerm_resource_group.rg.location
  resource_group_name = data.azurerm_resource_group.rg.name
  app_service_plan_id = azurerm_app_service_plan.my_app_service_plan.id

  site_config {
    dotnet_framework_version = var.dotnet_framework_version
    scm_type                 = var.scm_type
  }

  app_settings = {
    "SOME_KEY" = var.some_key
  }

  connection_string {
    name  = "${var.team}-db-connection-string"
    type  = var.connection_string_type
    value = var.connection_string_value
  }
}

resource "azurerm_app_service" "my_app_service2" {
  name                = "${var.team}-app-service2-${random_string.random.result}"
  location            = data.azurerm_resource_group.rg2.location
  resource_group_name = data.azurerm_resource_group.rg2.name
  app_service_plan_id = azurerm_app_service_plan.my_app_service_plan2.id

  site_config {
    dotnet_framework_version = var.dotnet_framework_version
    scm_type                 = var.scm_type
  }

  app_settings = {
    "SOME_KEY" = var.some_key
  }

  connection_string {
    name  = "${var.team}-db-connection-string"
    type  = var.connection_string_type
    value = var.connection_string_value
  }
}


resource "azurerm_storage_account" "my_storage_account" {
  name                     = "${var.team}dbstorage"
  resource_group_name      = data.azurerm_resource_group.rg.name
  location                 = data.azurerm_resource_group.rg.location
  account_tier             = var.account_tier
  account_replication_type = var.account_replication_type
}


resource "azurerm_sql_server" "primary_sql_server" {
  name                         = "${var.team}-sql-primary-${random_string.random.result}"
  resource_group_name          = data.azurerm_resource_group.rg.name
  location                     = data.azurerm_resource_group.rg.location
  version                      = "12.0"
  administrator_login          = data.azurerm_key_vault_secret.username.value
  administrator_login_password = data.azurerm_key_vault_secret.password.value
}

resource "azurerm_sql_server" "secondary" {
  name                         = "${var.team}-sql-secondary-${random_string.random.result}"
  resource_group_name          = data.azurerm_resource_group.rg2.name
  location                     = data.azurerm_resource_group.rg2.location
  version                      = "12.0"
  administrator_login          = data.azurerm_key_vault_secret.username.value
  administrator_login_password = data.azurerm_key_vault_secret.password.value
}

resource "azurerm_sql_database" "db1" {
  name                = "${var.team}-db1"
  resource_group_name = azurerm_sql_server.primary_sql_server.resource_group_name
  location            = azurerm_sql_server.primary_sql_server.location
  server_name         = azurerm_sql_server.primary_sql_server.name
}

resource "azurerm_sql_failover_group" "fallover_group" {
  name                = "${var.team}-failover-group"
  resource_group_name = azurerm_sql_server.primary_sql_server.resource_group_name
  server_name         = azurerm_sql_server.primary_sql_server.name
  databases           = [azurerm_sql_database.db1.id]
  partner_servers {
    id = azurerm_sql_server.secondary.id
  }

  read_write_endpoint_failover_policy {
    mode          = "Automatic"
    grace_minutes = 5
  }
}

