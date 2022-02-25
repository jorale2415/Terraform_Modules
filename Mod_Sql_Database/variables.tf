
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

variable "team" {
  type = string
  default = "Team5"
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
variable "some_key" {
  type = string
  default = "some-value"
}
variable "connection_string_type" {
  type = string
  default = "SQLServer"
}
variable "connection_string_value" {
  type = string
  default = "Server=some-server.mydomain.com;Integrated Security=SSPI"
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