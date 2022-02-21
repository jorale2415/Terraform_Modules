# Common Variables
variable "team" {
  type = string
}

# Region specific
variable "region" {
  type = string
}
variable "vnet" {
  type = string
}
variable "vnet-address" {
  type = list(string)
}

# Subnets
variable "subnet1" {
  type = string
}
variable "subnet2"{
    type = string
}
variable "subnet3"{
    type = string
}
variable "bastion"{
    type = string
}
variable "subnet1-prefix" {
  type = string
}
variable "subnet2-prefix" {
  type = string
}
variable "subnet3-prefix" {
  type = string
}

# Bastion
variable "bastion-prefix" {
  type = string
}
variable "bastion-pip" {
  type = string
}
variable "bastion-host" {
  type = string
}
variable "sku" {
  type = string
}
variable "allocation_method" {
  type = string
  default = "Static"
}

# Bastion nsg
variable "Internet-Bastion-PublicIP-Destination-Ports" {
  type = string
}
variable "OutboundVirtualNetwork-Destination-Ports" {
  type = list(string)
}
variable "Destination-Vnet-Address" {
  type = string
}


