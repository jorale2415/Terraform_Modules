
variable "resource_group1" {
  type = string
}
variable "resource_group2" {
  type = string
}
variable "resource_group3" {
  type = string
}
variable "app1_service_name" {
  type = string
}
variable "app2_service_name" {
  type = string
}

variable "Traffic_Manager_Profile_Name" {
  type = string
}
variable "traffic_routing_method" {
  type = string
  default = "Priority"
}
variable "Dns_Config_Name" {
  type = string
}
variable "protocol" {
  type = string
  default = "http"
}
variable "port" {
  type = number
  default = 80
}
variable "interval_in_seconds" {
  type = number
  default = 30
}
variable "timeout_in_seconds" {
  type = number
  default = 9
}
variable "tolerated_number_of_failures" {
  type = number
  default = 3
}
