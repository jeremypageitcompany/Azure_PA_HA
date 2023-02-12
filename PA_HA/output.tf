output "pip-mgmt-palovm1" {
  value = azurerm_public_ip.pip-mgmt-000["palovm1"].ip_address
}

output "pip-mgmt-palovm2" {
  value = azurerm_public_ip.pip-mgmt-000["palovm2"].ip_address
}
