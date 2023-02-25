# Nic

resource "azurerm_network_interface" "nic-mgmt-000" {
  for_each = var.palovm

  name                          = "nic_mgmt_${each.key}-${var.project}-${var.env}-${var.location}"
  location                      = var.location
  resource_group_name           = azurerm_resource_group.rg-001.name
  enable_accelerated_networking = false
  enable_ip_forwarding          = false

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.subnet-000["mgmt"].id
    private_ip_address_allocation = "Static"
    private_ip_address            = each.value.mgmt_ip
    public_ip_address_id          = azurerm_public_ip.pip-mgmt-000[each.key].id
  }
}

resource "azurerm_network_interface" "nic-untrust-000" {
  for_each = var.palovm

  name                          = "nic_untrust_${each.key}-${var.project}-${var.env}-${var.location}"
  location                      = var.location
  resource_group_name           = azurerm_resource_group.rg-001.name
  enable_accelerated_networking = true
  enable_ip_forwarding          = true

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.subnet-000["untrust"].id
    private_ip_address_allocation = "Static"
    private_ip_address            = each.value.untrust_ip
    primary                       = true
    public_ip_address_id          = (each.key == "palovm3" ? azurerm_public_ip.pip-untrust-001.id : (each.key == "palovm4" ? azurerm_public_ip.pip-untrust-002.id : null))
  }

}


resource "azurerm_network_interface" "nic-trust-000" {
  for_each = var.palovm

  name                          = "nic_trust_${each.key}-${var.project}-${var.env}-${var.location}"
  location                      = var.location
  resource_group_name           = azurerm_resource_group.rg-001.name
  enable_accelerated_networking = true
  enable_ip_forwarding          = true

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.subnet-000["trust"].id
    private_ip_address_allocation = "Static"
    private_ip_address            = each.value.trust_ip
    primary                       = true
  }

}


# VM

resource "azurerm_virtual_machine" "vm-palo-000" {
  for_each = var.palovm

  name                = "${each.key}-${var.project}-${var.env}-${var.location}"
  location            = var.location
  resource_group_name = azurerm_resource_group.rg-001.name
  tags                = var.resource_tags
  vm_size             = var.vm_size

  plan {
    name      = var.vm_sku
    publisher = var.vm_publisher
    product   = var.vm_offer
  }

  storage_image_reference {
    publisher = var.vm_publisher
    offer     = var.vm_offer
    sku       = var.vm_sku
    version   = var.vm_version
  }

  storage_os_disk {
    name          = "disk_${each.key}-${var.project}-${var.env}-${var.location}"
    create_option = "FromImage"
  }

  os_profile {
    computer_name  = each.key
    admin_username = var.vm_username
    admin_password = var.vm_password
  }

  primary_network_interface_id = azurerm_network_interface.nic-mgmt-000[each.key].id
  network_interface_ids = [
    azurerm_network_interface.nic-mgmt-000[each.key].id,
    azurerm_network_interface.nic-untrust-000[each.key].id,
    azurerm_network_interface.nic-trust-000[each.key].id,
  ]

  os_profile_linux_config {
    disable_password_authentication = false
  }

}