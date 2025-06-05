output "resource_group_name" {
  description = "Name of the resource group"
  value       = module.resource_group.name
}

output "vnet_id" {
  description = "ID of the virtual network"
  value       = module.network.vnet_id
}

output "aks_subnet_id" {
  description = "ID of the AKS subnet"
  value       = module.network.aks_subnet_id
}

output "kubernetes_cluster_name" {
  description = "Name of the AKS cluster"
  value       = module.aks.cluster_name
}

output "kube_config" {
  description = "Kubernetes configuration"
  value       = module.aks.kube_config
  sensitive   = true
}

output "client_certificate" {
  description = "Client certificate for authentication"
  value       = module.aks.client_certificate
  sensitive   = true
}

output "client_key" {
  description = "Client key for authentication"
  value       = module.aks.client_key
  sensitive   = true
}

output "cluster_ca_certificate" {
  description = "Cluster CA certificate"
  value       = module.aks.cluster_ca_certificate
  sensitive   = true
}

output "host" {
  description = "Kubernetes cluster server host"
  value       = module.aks.host
  sensitive   = true
}