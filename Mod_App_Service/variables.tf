variable "team" {
  type = string
  default = "Team5"
}
variable "resource_group" {
  type = string
}
variable "app_service_name" {
  type = string
}
variable "app_service_plan_name" {
  type = string
}

variable "AS_Sku_Tier" {
  type = string
  default = "Standard"
}

variable "AS_Sku_Size" {
  type = string
}