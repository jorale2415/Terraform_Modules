
variable "key_vault" {
  type = string
  default = "jalex-key-vault"
}
variable "key_vault_rg" {
  type = string
  default = "jalex-storage-rg"
}
variable "secret_username" {
  type = string
  default = "db-username"
}
variable "secret_password" {
  type = string
  default = "db-password"
}

variable "primary_resource_group_name" {
  type = string
}
variable "secondary_resource_group_name" {
  type = string 
}
variable "rg1_vnet" {
  type = string
}
variable "rg2_vnet" {
  type = string
}

variable "web_subnet_primary_region" {
  type = string
}
variable "web_subnet_secondary_region" {
  type = string
}


variable "team" {
  type = string
  default = "team5"
}
variable "asp_sku" {
  type = string
  default = "Standard"
}
variable "asp_tier" {
  type = string
  default = "S1"
}   
variable "dotnet_framework_version" {
  type = string
  default = "v4.0"
}
variable "scm_type" {
  type = string
  default = "LocalGit"
}
variable "database_server1" {
  type = string
  default = "DatabaseServer=team5-failover-group.database.windows.net"
}
variable "database_server2" {
  type = string
  default = "team5-failover-group.secondary.database.windows.net"
}
variable "connection_string_type" {
  type = string
  default = "SQLServer"
}

variable "connection_string_value" {
  type = string
  default = "Server=team5-failover-group.database.windows.net;Integrated Security=SSPI"
}
variable "connection_string_value2" {
  type = string
  default = "Server=team5-failover-group.secondary.database.windows.net;Integrated Security=SSPI"
}
variable "storage_account_name" {
  type = string
  default = "jalex-db-storage-account"
}
variable "account_tier" {
  type = string
  default = "Standard"
}
variable "account_replication_type" {
  type = string
  default = "GRS"
}