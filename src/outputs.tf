output "resource_group_name" {
  description = "Name of the resource group."
  value       = azurerm_resource_group.main.name
}

output "vnet_id" {
  description = "Resource ID of the virtual network."
  value       = azurerm_virtual_network.main.id
}

output "aks_subnet_id" {
  description = "Resource ID of the AKS subnet."
  value       = azurerm_subnet.aks.id
}

output "db_subnet_id" {
  description = "Resource ID of the database subnet."
  value       = azurerm_subnet.db.id
}

output "aks_cluster_name" {
  description = "Name of the AKS cluster."
  value       = azurerm_kubernetes_cluster.main.name
}

output "aks_cluster_id" {
  description = "Resource ID of the AKS cluster."
  value       = azurerm_kubernetes_cluster.main.id
}

output "aks_kube_config_command" {
  description = "az CLI command to configure kubectl."
  value       = "az aks get-credentials --resource-group ${azurerm_resource_group.main.name} --name ${azurerm_kubernetes_cluster.main.name}"
}

output "acr_login_server" {
  description = "Login server URL for the container registry."
  value       = azurerm_container_registry.main.login_server
}

output "acr_id" {
  description = "Resource ID of the container registry."
  value       = azurerm_container_registry.main.id
}
