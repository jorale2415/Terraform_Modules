variable "vnet_name" {
  type = string
}
variable "vnet_location" {
  type = string
}
variable "vnet_rg_name" {
  type = string
}
variable "vnet_address_space" {
  type = list(string)
}
variable "vnet_dns_servers" {
  type = list(string)
}
variable "number_of_subnets" {
  type = number
}
