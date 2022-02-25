# define a terraform bolck and specify verison required
terraform {
  required_version = ">= 1.1.5"
}

# *************** Data calls from exsisting resources ******************
data "azurerm_resource_group" "rg" {
  name = var.resource_group
}
data "azurerm_key_vault" "existing" {
  name                = var.key_vault
  resource_group_name = var.key_vault_rg
}
data "azurerm_key_vault_secret" "username" {
  name         = var.secret_username
  key_vault_id = data.azurerm_key_vault.existing.id
}
data "azurerm_key_vault_secret" "password" {
  name         = var.secret_password
  key_vault_id = data.azurerm_key_vault.existing.id
}
data "azurerm_subnet" "my_subnet" {
  name = var.subnet
  virtual_network_name = var.vnet
  resource_group_name = data.azurerm_resource_group.rg.name
}
# ******************* End of data calls **********************************


# ********************** Virtual machine scale set ************************

resource "azurerm_linux_virtual_machine_scale_set" "Business_vmss" {
  name                = "${var.subnet}-vmss"
  resource_group_name = data.azurerm_resource_group.rg.name
  location            = data.azurerm_resource_group.rg.location
  sku                 = var.vm_sku
  instances           = var.instances
  admin_username      = data.azurerm_key_vault_secret.username.value
  admin_password      = data.azurerm_key_vault_secret.password.value
  disable_password_authentication = false

  source_image_reference {
    publisher = var.image_publisher
    offer     = var.image_offer
    sku       = var.image_sku
    version   = var.image_version
  }

  os_disk {
    storage_account_type = var.storage_account_type
    caching              = var.caching
  }

  network_interface {
    name    = "${var.subnet}-NIC"
    primary = var.primary

    ip_configuration {
      name      = "${var.subnet}-NIC-IP-CONFIG"
      primary   = var.primary_ip
      subnet_id = data.azurerm_subnet.my_subnet.id
      load_balancer_backend_address_pool_ids = [azurerm_lb_backend_address_pool.internal_be_pool.id]
    }
  }
}

# ********************** End Virtual machine scale set ************************

# ********************************* Internal Load Balancer ***********************************************

resource "azurerm_public_ip" "pip" {
  name                = "${var.team}-${var.region}-InternalLoadBalancer-PIP"
  location            = data.azurerm_resource_group.rg.location
  resource_group_name = data.azurerm_resource_group.rg.name
  allocation_method   = "Static"
  domain_name_label = lower("${var.team}-${var.region}-InternalLoadBalancer")
}

resource "azurerm_lb" "internal_lb" {
  name                = "${var.team}-${var.region}-InternalLoadBalancer"
  location            = data.azurerm_resource_group.rg.location
  resource_group_name = data.azurerm_resource_group.rg.name

  frontend_ip_configuration {
    name                          = "${var.team}-${var.region}-InternalLoadBalancer-FE-IP"
    #public_ip_address_id          = var.type == "public" ? join("", azurerm_public_ip.azlb.*.id) : ""
    subnet_id                     = data.azurerm_subnet.my_subnet.id
    private_ip_address            = var.frontend_private_ip_address
    private_ip_address_allocation = var.frontend_private_ip_address_allocation
  }
}

resource "azurerm_lb_backend_address_pool" "internal_be_pool" {
  name                = "${var.team}-${var.region}-InternalLoadBalancer-BE-POOL"
  loadbalancer_id     = azurerm_lb.internal_lb.id
}

resource "azurerm_lb_rule" "Lb_rule" {
  resource_group_name            = data.azurerm_resource_group.rg.name
  loadbalancer_id                = azurerm_lb.internal_lb.id   
  name                           = "HTTP-Access"
  protocol                       = "Tcp"
  frontend_port                  = 80
  backend_port                   = 80
  frontend_ip_configuration_name = "${var.team}-${var.region}-InternalLoadBalancer-FE-IP"
  backend_address_pool_id        = azurerm_lb_backend_address_pool.internal_be_pool.id
  probe_id                       = azurerm_lb_probe.health_probe.id 
}
resource "azurerm_lb_rule" "Lb_rule2" {
  resource_group_name            = data.azurerm_resource_group.rg.name
  loadbalancer_id                = azurerm_lb.internal_lb.id   
  name                           = "SQLAlwaysOnEndPointListener"
  protocol                       = "Tcp"
  frontend_port                  = 1433
  backend_port                   = 1433
  frontend_ip_configuration_name = "${var.team}-${var.region}-InternalLoadBalancer-FE-IP"
  backend_address_pool_id        = azurerm_lb_backend_address_pool.internal_be_pool.id
  probe_id                       = azurerm_lb_probe.health_probe.id 
  enable_floating_ip             = true
}


resource "azurerm_lb_probe" "health_probe" {
  resource_group_name = data.azurerm_resource_group.rg.name
  loadbalancer_id     = azurerm_lb.internal_lb.id
  name                = "http-probe"
  port                = 80
}

# ********************************* Internal Load Balancer ***********************************************