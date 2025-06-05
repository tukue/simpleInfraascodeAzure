provider "azurerm" {
  features {}
  
  # These will be provided by environment variables:
  # ARM_SUBSCRIPTION_ID, ARM_CLIENT_ID, ARM_CLIENT_SECRET, ARM_TENANT_ID
  use_oidc = false
}

module "resource_group" {
  source = "../../modules/resource_group"
  
  resource_group_name = var.resource_group_name
  location            = var.location
  tags                = local.tags
}

module "network" {
  source = "../../modules/network"
  
  vnet_name           = "${var.cluster_name}-vnet"
  resource_group_name = module.resource_group.resource_group_name
  location            = module.resource_group.location
  prefix              = var.cluster_name
  tags                = local.tags
}

module "aks" {
  source = "../../modules/aks"
  
  cluster_name        = var.cluster_name
  resource_group_name = module.resource_group.resource_group_name
  location            = module.resource_group.location
  kubernetes_version  = var.kubernetes_version
  node_count          = var.node_count
  vm_size             = var.vm_size
  subnet_id           = module.network.aks_subnet_id
  tags                = local.tags
}

locals {
  tags = merge(var.tags, {
    Environment = var.environment
  })
}