# Configure the Azure provider
provider "azurerm" {
  features {}
  
  # These will be provided by environment variables:
  # ARM_SUBSCRIPTION_ID, ARM_CLIENT_ID, ARM_CLIENT_SECRET, ARM_TENANT_ID
  use_oidc = false
}

# Create a resource group
module "resource_group" {
  source = "./modules/resource_group"

  name     = var.resource_group_name
  location = var.location
  tags     = var.tags
}

# Create network infrastructure
module "network" {
  source = "./modules/network"

  vnet_name           = "${var.prefix}-vnet"
  location            = module.resource_group.location
  resource_group_name = module.resource_group.name
  address_space       = var.vnet_address_space
  aks_subnet_prefix   = var.aks_subnet_prefix
  prefix             = var.prefix
  tags               = var.tags

  depends_on = [module.resource_group]
}

# Create AKS cluster
module "aks" {
  source = "./modules/aks"

  cluster_name        = var.cluster_name
  location            = module.resource_group.location
  resource_group_name = module.resource_group.name
  kubernetes_version  = var.kubernetes_version
  node_count         = var.node_count
  min_node_count     = var.min_node_count
  max_node_count     = var.max_node_count
  vm_size            = var.vm_size
  subnet_id          = module.network.aks_subnet_id
  dns_service_ip     = var.dns_service_ip
  docker_bridge_cidr = var.docker_bridge_cidr
  service_cidr       = var.service_cidr
  
  tags = merge(var.tags, {
    Environment = var.environment
  })

  depends_on = [module.network]
}