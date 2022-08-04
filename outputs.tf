output "resource_group_id" {
  value = azurerm_resource_group.hub-vnet-rg.id
}

output "hubvnet_id" {
  value = azurerm_virtual_network.hub-vnet.id
}