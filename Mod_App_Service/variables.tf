variable "team" {
  type = string
  default = "Team5"
}
variable "app-service" {
  type = map(
    object({
        NAME = list(string)
        LOCATION = list(string)
    })
  )
  default = {
    "key" = {
      NAME = ["App-Service1", "App-Service2"]
      LOCATION = ["eastus", "westus2"]
    }
  }
}

variable "rg-location" {
  type = string
  default = "eastus"
}

variable "app-sku" {
  type = map(
    object({
      TIER = list(string)
      SIZE = list(string)
    })
  )
  default = {
    "key" = {
      TIER = ["Standard", "Standard"]
      SIZE = ["S1", "S2"]
    }
  }
}
