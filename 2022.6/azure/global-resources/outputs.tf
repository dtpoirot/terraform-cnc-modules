output "rg_name" {
  value = resource.azurerm_resource_group.rg.name
}
output "rg_location" {
  value = resource.azurerm_resource_group.rg.location
}
output "vnet_name" {
  value = resource.azurerm_virtual_network.vnet.name
}

output "vnet_id" {
  value = resource.azurerm_virtual_network.vnet.id
}

output "subnetid" {
  value = resource.azurerm_subnet.subnet.id
}

output "delegated_subnet_id" {
  value = resource.azurerm_subnet.delegated_subnet.id
}

output "publicip" {
  value = resource.azurerm_public_ip.publicip.ip_address
}

output "cluster_name" {
  value = azurerm_kubernetes_cluster.aks.name
}