# define a terraform bolck and specify verison required
terraform {
  required_version = ">= 1.1.5"
}

#************************* Start Data Calls *************************************************

data "azurerm_resource_group" "rg" {
  name = "${var.team}-${var.region}-rg"
}
data "azurerm_subnet" "bastion_subnet" {
  name = var.bastion
  virtual_network_name = azurerm_virtual_network.vnet.name
  resource_group_name = data.azurerm_resource_group.rg.name
}

#************************* End Data Calls ****************************************************


#************************* Start Network security groups *************************************

resource "azurerm_network_security_group" "bastionnsg" {
  name                = "bastionnsg"
  location            = data.azurerm_resource_group.rg.location
  resource_group_name = data.azurerm_resource_group.rg.name

  security_rule {
        name                       = "GatewayManager"
        priority                   = 1001
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range     = "443"
        source_address_prefix      = "GatewayManager"
        destination_address_prefix = "*"
    }
    
    security_rule {
        name                       = "Internet-Bastion-PublicIP"
        priority                   = 1002
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range     = var.Internet-Bastion-PublicIP-Destination-Ports
        source_address_prefix      = "*"
        destination_address_prefix = "*"
    }

    security_rule {
        name                       = "OutboundVirtualNetwork"
        priority                   = 1001
        direction                  = "Outbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_ranges    = var.OutboundVirtualNetwork-Destination-Ports
        source_address_prefix      = "*"
        destination_address_prefix = "VirtualNetwork"
    }
    
     security_rule {
        name                       = "OutboundToAzureCloud"
        priority                   = 1002
        direction                  = "Outbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range     = "443"
        source_address_prefix      = "*"
        destination_address_prefix = "AzureCloud"
    }
}

#************************* End Network security groups ***********************************


#************************* Start Bastion *************************************************

resource "azurerm_public_ip" "bastion_pip" {
  name                = var.bastion-pip
  location            = data.azurerm_resource_group.rg.location
  resource_group_name = data.azurerm_resource_group.rg.name
  allocation_method   = var.allocation_method
  sku                 = var.sku
}

resource "azurerm_bastion_host" "bastion_host" {
  name                = var.bastion-host
  location            = data.azurerm_resource_group.rg.location
  resource_group_name = data.azurerm_resource_group.rg.name

  ip_configuration {
    name                 = "configuration"
    subnet_id            = data.azurerm_subnet.bastion_subnet.id
    public_ip_address_id = azurerm_public_ip.bastion_pip.id
  }
}

#************************* End Bastion ***************************************************


#************************* Start Virtual Network *****************************************

resource "azurerm_virtual_network" "vnet" {
  name                = var.vnet
  location            = data.azurerm_resource_group.rg.location
  resource_group_name = data.azurerm_resource_group.rg.name
  address_space       = var.vnet-address

  subnet {
    name           = var.subnet1
    address_prefix = var.subnet1-prefix
    security_group = azurerm_network_security_group.bastionnsg.id
  }

  subnet {
      name           = var.subnet2
      address_prefix = var.subnet2-prefix
      security_group = azurerm_network_security_group.bastionnsg.id
  }

  subnet {
    name           = var.subnet3
    address_prefix = var.subnet3-prefix
    security_group = azurerm_network_security_group.bastionnsg.id
  }
  subnet {
    name           = var.bastion
    address_prefix = var.bastion-prefix
    security_group = azurerm_network_security_group.bastionnsg.id
  }
}

#************************* End Virtual Network *************************************************

