variable "vnet_name" {
  description = "Then name of your vnet."
  type = string
}
variable "vnet_location" {
  description = "The location of your vnet."
  type = string
  default = "eastus"
}
variable "vnet_rg_name" {
  description = "The name of your resource group you want the Vnet to be in."
  type = string
}
variable "vnet_address_space" {
  description = "The Vnet address space."
  type = list(string)
}
variable "vnet_dns_servers" {
  description = "The Vnet dns servers addressess."
  type = list(string)
}
variable "number_of_subnets" {
  description = "The number of subnets you want in the Vnet."
  type = number
}
