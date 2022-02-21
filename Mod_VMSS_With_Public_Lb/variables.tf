# ************ Common Variables******************
variable "team" {
  type = string
}

# ************** Key vault variables ************
variable "key_vault" {
  type = string
}
variable "key_vault_rg" {
  type = string
}
variable "secret_username" {
  type = string
}
variable "secret_password" {
  type = string
}

# **************** Region specific *************
variable "region" {
  type = string
}
variable "vnet" {
  type = string
}

# Subnets
variable "subnet" {
  type = string
}

#**********  Virtual machine scale set **********
# VM 
variable "vm_sku" {
  type = string
  default = "Standard_B1s"
}
variable "instances" {
  type = number
  default = 1
}

# Source Image Reference
variable "image_publisher" {
  type = string
  default = "Canonical"
}
variable "image_offer" {
  type = string
  default = "UbuntuServer"
}
variable "image_sku" {
  type = string
  default = "18.04-LTS"
}
variable "image_version" {
  type = string
  default = "latest"
}

# OS Disk
variable "storage_account_type" {
  type = string
  default = "Standard_LRS"
}
variable "caching" {
  type = string
  default = "ReadWrite"
}

 # NIC
variable "primary" {
  type = string
  default = "true"
}

# NIC IP Configuration
variable "primary_ip" {
  type = string
  default = "true"
}