output "resource_group_name" {
  description = "Name of the Azure Resource Group"
  value       = azurerm_resource_group.rg.name
}

output "acr_login_server" {
  description = "ACR login server URL (use this to push Docker images)"
  value       = azurerm_container_registry.acr.login_server
}

output "aks_cluster_name" {
  description = "Name of the AKS cluster"
  value       = azurerm_kubernetes_cluster.aks.name
}

output "aks_kube_config_command" {
  description = "Run this command to configure kubectl to connect to AKS"
  value       = "az aks get-credentials --resource-group ${azurerm_resource_group.rg.name} --name ${azurerm_kubernetes_cluster.aks.name}"
}

output "deployment_info" {
  description = "Steps to follow after terraform apply"
  value       = <<EOT
1. Update ACR_SERVER in .github/workflows/deploy.yml with: ${azurerm_container_registry.acr.login_server}
2. Run: az aks get-credentials --resource-group ${azurerm_resource_group.rg.name} --name ${azurerm_kubernetes_cluster.aks.name}
3. Run: kubectl apply -f k8s/namespace.yaml
4. Run: kubectl apply -f k8s/
EOT
}
