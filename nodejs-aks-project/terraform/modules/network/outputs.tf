output "vnet_id" {
  description = "ID of the created virtual network"
  value       = azurerm_virtual_network.this.id
}

output "aks_subnet_id" {
  description = "ID of the AKS subnet"
  value       = azurerm_subnet.aks.id
}

output "nsg_id" {
  description = "ID of the network security group"
  value       = azurerm_network_security_group.aks.id
}