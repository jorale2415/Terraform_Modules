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
data "azurerm_virtual_network" "rg1_vnet" {
  name                = var.rg1_vnet
  resource_group_name = data.azurerm_resource_group.rg.name
}
data "azurerm_virtual_network" "rg2_vnet" {
  name                = var.rg2_vnet
  resource_group_name = data.azurerm_resource_group.rg2.name
}
data "azurerm_subnet" "rg1_subnet" {
  name = var.web_subnet_primary_region
  virtual_network_name = data.azurerm_virtual_network.rg1_vnet.name
  resource_group_name  = data.azurerm_resource_group.rg.name
}
data "azurerm_subnet" "rg2_subnet" {
  name = var.web_subnet_secondary_region
  virtual_network_name = data.azurerm_virtual_network.rg2_vnet.name
  resource_group_name  = data.azurerm_resource_group.rg2.name
}

/*
resource "azurerm_app_service_environment" "app_service_env_primary_region" {
  name                         = "${var.team}-ase"
  subnet_id                    = data.azurerm_subnet.rg1_subnet.id
  pricing_tier                 = "I2"
  front_end_scale_factor       = 10
  internal_load_balancing_mode = "Web, Publishing"

  cluster_setting {
    name  = "DisableTls1.0"
    value = "1"
  }
}
resource "azurerm_app_service_environment" "app_service_env_secondary_region" {
  name                         = "${var.team}-ase"
  subnet_id                    = data.azurerm_subnet.rg2_subnet.id
  pricing_tier                 = "I2"
  front_end_scale_factor       = 10
  internal_load_balancing_mode = "Web, Publishing"

  cluster_setting {
    name  = "DisableTls1.0"
    value = "1"
  }
}
*/

resource "azurerm_app_service_plan" "my_app_service_plan" {
  name                = "${var.team}-app-service-plan1"
  location            = data.azurerm_resource_group.rg.location
  resource_group_name = data.azurerm_resource_group.rg.name

  sku {
    tier = var.asp_sku
    size = var.asp_tier
  }
}

resource "azurerm_app_service_plan" "my_app_service_plan2" {
  name                = "${var.team}-app-service-plan2"
  location            = data.azurerm_resource_group.rg2.location
  resource_group_name = data.azurerm_resource_group.rg2.name

  sku {
    tier = var.asp_sku
    size = var.asp_tier
  }
}

resource "azurerm_app_service" "my_app_service" {
  name                = "${var.team}-app-service-012421"
  location            = data.azurerm_resource_group.rg.location
  resource_group_name = data.azurerm_resource_group.rg.name
  app_service_plan_id = azurerm_app_service_plan.my_app_service_plan.id

  site_config {
    dotnet_framework_version = var.dotnet_framework_version
    scm_type                 = var.scm_type
  }

  app_settings = {
    "SOME_KEY" = var.database_server1
  }

  connection_string {
    name  = "${var.team}-db-connection-string"
    type  = var.connection_string_type
    value = var.connection_string_value
  }
}

resource "azurerm_app_service" "my_app_service2" {
  name                = "${var.team}-app-service2-131246"
  location            = data.azurerm_resource_group.rg2.location
  resource_group_name = data.azurerm_resource_group.rg2.name
  app_service_plan_id = azurerm_app_service_plan.my_app_service_plan2.id

  site_config {
    dotnet_framework_version = var.dotnet_framework_version
    scm_type                 = var.scm_type
  }

  app_settings = {
    "DatabaseServer1" = var.database_server2
  }

  connection_string {
    name  = "${var.team}-db-connection-string"
    type  = var.connection_string_type
    value = var.connection_string_value2
  }
}


resource "azurerm_storage_account" "my_storage_account" {
  name                     = "${var.team}dbstorage"
  resource_group_name      = data.azurerm_key_vault.existing.resource_group_name
  location                 = data.azurerm_key_vault.existing.location
  account_tier             = var.account_tier
  account_replication_type = var.account_replication_type
}


resource "azurerm_sql_server" "primary_sql_server" {
  name                         = "${var.team}-sql-primary"
  resource_group_name          = data.azurerm_resource_group.rg.name
  location                     = data.azurerm_resource_group.rg.location
  version                      = "12.0"
  administrator_login          = data.azurerm_key_vault_secret.username.value
  administrator_login_password = data.azurerm_key_vault_secret.password.value
}

resource "azurerm_sql_server" "secondary" {
  name                         = "${var.team}-sql-secondary"
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
    grace_minutes = 60
  }
}

