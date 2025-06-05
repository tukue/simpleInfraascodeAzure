output "resource_group_name" {
  value = module.resource_group.resource_group_name
}

output "cluster_name" {
  value = module.aks.cluster_name
}

output "cluster_id" {
  value = module.aks.cluster_id
}

output "kube_config" {
  value     = module.aks.kube_config
  sensitive = true
}

output "host" {
  value     = module.aks.host
  sensitive = true
}

output "client_certificate" {
  value     = module.aks.client_certificate
  sensitive = true
}