terraform {
  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
    }
  }
}

provider "azurerm" {
  features {}

}

# Resource Group
resource "azurerm_resource_group" "rg-001" {
  name     = "rg-${var.project}-${var.env}-${var.location}"
  location = var.location
  tags     = var.resource_tags
}

# Vnet
resource "azurerm_virtual_network" "vnet-001" {
  name                = "vnet-${var.project}-${var.env}-${var.location}"
  resource_group_name = azurerm_resource_group.rg-001.name
  location            = var.location
  address_space       = [var.subnet_vnet]
  tags                = var.resource_tags
}

# Subnet
resource "azurerm_subnet" "subnet-000" {
  for_each = var.subnet

  name                 = "subnet_${each.key}-${var.project}-${var.env}-${var.location}"
  resource_group_name  = azurerm_resource_group.rg-001.name
  virtual_network_name = azurerm_virtual_network.vnet-001.name
  address_prefixes     = each.value.prefix

}

# NSG
resource "azurerm_network_security_group" "nsg-001" {
  name                = "nsg_mgmt-${var.project}-${var.env}-${var.location}"
  location            = var.location
  resource_group_name = azurerm_resource_group.rg-001.name
  tags                = var.resource_tags

  security_rule = [{
    access                                     = "Allow"
    description                                = "AllowInboundHome"
    destination_address_prefix                 = "*"
    destination_port_range                     = ""
    direction                                  = "Inbound"
    name                                       = "AllowInboundSSHhome"
    priority                                   = 100 # between 100 - 4096
    protocol                                   = "Tcp"
    source_address_prefix                      = "${chomp(data.http.myip.response_body)}"
    source_port_range                          = "*"
    destination_address_prefixes               = []
    destination_application_security_group_ids = []
    destination_port_ranges                    = ["22", "443"]
    source_address_prefixes                    = []
    source_application_security_group_ids      = []
    source_port_ranges                         = []
  }]
}

resource "azurerm_network_security_group" "nsg-002" {
  name                = "nsg_untrust-${var.project}-${var.env}-${var.location}"
  location            = var.location
  resource_group_name = azurerm_resource_group.rg-001.name
  tags                = var.resource_tags

  security_rule = [{
    access                                     = "Allow"
    description                                = "AllowInboundHome"
    destination_address_prefix                 = "*"
    destination_port_range                     = ""
    direction                                  = "Inbound"
    name                                       = "AllowInboundSSHhome"
    priority                                   = 100 # between 100 - 4096
    protocol                                   = "Tcp"
    source_address_prefix                      = "${chomp(data.http.myip.response_body)}"
    source_port_range                          = "*"
    destination_address_prefixes               = []
    destination_application_security_group_ids = []
    destination_port_ranges                    = ["443"]
    source_address_prefixes                    = []
    source_application_security_group_ids      = []
    source_port_ranges                         = []
  }]
}

resource "azurerm_subnet_network_security_group_association" "assoc_nsg-001" {
  subnet_id                 = azurerm_subnet.subnet-000["mgmt"].id
  network_security_group_id = azurerm_network_security_group.nsg-001.id
}

resource "azurerm_subnet_network_security_group_association" "assoc_nsg-002" {
  subnet_id                 = azurerm_subnet.subnet-000["untrust"].id
  network_security_group_id = azurerm_network_security_group.nsg-002.id
}

resource "azurerm_public_ip" "pip-mgmt-000" {
  for_each = var.palovm

  name                = "pip_mgmt_${each.key}-${var.project}-${var.env}-${var.location}"
  location            = var.location
  resource_group_name = azurerm_resource_group.rg-001.name
  allocation_method   = "Static"
  tags                = var.resource_tags
  sku                 = var.public_ip_sku
}

resource "azurerm_public_ip" "pip-lb-frontend-001" {

  name                = "pip_lb-frontend-${var.project}-${var.env}-${var.location}"
  location            = var.location
  resource_group_name = azurerm_resource_group.rg-001.name
  allocation_method   = "Static"
  tags                = var.resource_tags
  sku                 = var.public_ip_sku
}