# Subnet
resource "azurerm_subnet" "subnet-server" {
  name                 = "subnet_server-${var.project}-${var.env}-${var.location}"
  resource_group_name  = azurerm_resource_group.rg-001.name
  virtual_network_name = azurerm_virtual_network.vnet-001.name
  address_prefixes     = var.subnet_server
}

# Nic
resource "azurerm_network_interface" "nic-linux-001" {
  name                = "nic_linux-${var.project}-${var.env}-${var.location}"
  location            = var.location
  resource_group_name = azurerm_resource_group.rg-001.name
  tags                = var.resource_tags

  ip_configuration {

    name                          = "internal"
    subnet_id                     = azurerm_subnet.subnet-server.id
    private_ip_address_allocation = "Dynamic"
  }
}

#VM linux
resource "azurerm_linux_virtual_machine" "vmLinux" {
  name                = "vm-linux-${var.project}-${var.env}-${var.location}"
  resource_group_name = azurerm_resource_group.rg-001.name
  location            = var.location
  size                = "Standard_F2"
  admin_username      = var.vm_username
  tags                = var.resource_tags

  # If not using ssh key, require to set password auth to false
  disable_password_authentication = false
  admin_password                  = var.vm_password


  network_interface_ids = [
    azurerm_network_interface.nic-linux-001.id
  ]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
    name                 = "disk_linux-${var.project}-${var.env}-${var.location}"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "16.04-LTS"
    version   = "latest"
  }
}

# UDR
resource "azurerm_route_table" "udr_server" {
  name                          = "udr-server-${var.project}-${var.env}-${var.location}"
  location                      = var.location
  resource_group_name           = azurerm_resource_group.rg-001.name
  tags                          = var.resource_tags
  disable_bgp_route_propagation = true

  route {
    name                   = "DefaultRoutePaloTrust"
    address_prefix         = "0.0.0.0/0"
    next_hop_type          = "VirtualAppliance"
    next_hop_in_ip_address = var.palovm.palovm1.floating_trust_ip
  }

}

resource "azurerm_subnet_route_table_association" "association_subnet_server" {
  subnet_id      = azurerm_subnet.subnet-server.id
  route_table_id = azurerm_route_table.udr_server.id
}