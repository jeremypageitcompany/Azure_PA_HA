# Public LB
resource "azurerm_lb" "lb-public-001" {
  name                = "lb_public-${var.project}-${var.env}-${var.location}"
  location            = var.location
  resource_group_name = azurerm_resource_group.rg-001.name
  sku                 = var.lb_sku

  frontend_ip_configuration {
    name                 = "FrontEnd"
    public_ip_address_id = azurerm_public_ip.pip-lb-frontend-001.id
  }
}

resource "azurerm_lb_probe" "lb-public-probe-001" {
  name                = "lb_public_probe-${var.project}-${var.env}-${var.location}"
  loadbalancer_id     = azurerm_lb.lb-public-001.id
  port                = 22
  protocol            = "Tcp"
  interval_in_seconds = 5
}

resource "azurerm_lb_backend_address_pool" "lb-public-backend-001" {
  name            = "lb_public_backend-${var.project}-${var.env}-${var.location}"
  loadbalancer_id = azurerm_lb.lb-public-001.id
}

resource "azurerm_lb_backend_address_pool_address" "lb-public-backend-address-001" {
  for_each = var.palovm

  name                    = "lb_public_backend_address-${each.key}-${var.project}-${var.env}-${var.location}"
  backend_address_pool_id = azurerm_lb_backend_address_pool.lb-public-backend-001.id
  virtual_network_id      = azurerm_virtual_network.vnet-001.id
  ip_address              = each.value.untrust_ip
  depends_on = [
    azurerm_resource_group.rg-001
  ]
}


resource "azurerm_lb_rule" "lb-public-rule-001" {
  name                           = "lb_public_rule-${var.project}-${var.env}-${var.location}"
  loadbalancer_id                = azurerm_lb.lb-public-001.id
  protocol                       = "Tcp"
  frontend_port                  = 8000
  backend_port                   = 8000
  frontend_ip_configuration_name = azurerm_lb.lb-public-001.frontend_ip_configuration[0].name
  backend_address_pool_ids       = [azurerm_lb_backend_address_pool.lb-public-backend-001.id]
  probe_id                       = azurerm_lb_probe.lb-public-probe-001.id
  enable_floating_ip             = true
}

# Internal LB
resource "azurerm_lb" "lb-internal-001" {
  name                = "lb_internal-${var.project}-${var.env}-${var.location}"
  location            = var.location
  resource_group_name = azurerm_resource_group.rg-001.name
  sku                 = var.lb_sku

  frontend_ip_configuration {
    name               = "FrontEnd"
    private_ip_address = var.frontend_ip_internal_lb
    subnet_id = azurerm_subnet.subnet-000["trust"].id
    private_ip_address_allocation = "Static"
  }
}

resource "azurerm_lb_probe" "lb-internal-probe-001" {
  name                = "lb_internal_probe-${var.project}-${var.env}-${var.location}"
  loadbalancer_id     = azurerm_lb.lb-internal-001.id
  port                = 22
  protocol            = "Tcp"
  interval_in_seconds = 5
}

resource "azurerm_lb_backend_address_pool" "lb-internal-backend-001" {
  name            = "lb_internal_backend-${var.project}-${var.env}-${var.location}"
  loadbalancer_id = azurerm_lb.lb-internal-001.id
}

resource "azurerm_lb_backend_address_pool_address" "lb-internal-backend-address-001" {
  for_each = var.palovm

  name                    = "lb_internal_backend_address-${each.key}-${var.project}-${var.env}-${var.location}"
  backend_address_pool_id = azurerm_lb_backend_address_pool.lb-internal-backend-001.id
  virtual_network_id      = azurerm_virtual_network.vnet-001.id
  ip_address              = each.value.trust_ip
  depends_on = [
    azurerm_resource_group.rg-001
  ]
}

resource "azurerm_lb_rule" "lb-internal-rule-001" {
  name                           = "lb_internal_rule-${var.project}-${var.env}-${var.location}"
  loadbalancer_id                = azurerm_lb.lb-internal-001.id
  protocol                       = "All" # https://github.com/hashicorp/terraform-provider-azurerm/issues/372
  backend_port                   = 0     # https://github.com/hashicorp/terraform-provider-azurerm/issues/372
  frontend_port                  = 0     # https://github.com/hashicorp/terraform-provider-azurerm/issues/372
  frontend_ip_configuration_name = azurerm_lb.lb-internal-001.frontend_ip_configuration[0].name
  backend_address_pool_ids       = [azurerm_lb_backend_address_pool.lb-internal-backend-001.id]
  probe_id                       = azurerm_lb_probe.lb-internal-probe-001.id
}