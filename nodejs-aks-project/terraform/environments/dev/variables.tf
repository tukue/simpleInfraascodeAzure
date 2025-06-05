variable "resource_group_name" {
  description = "Name of the resource group"
  type        = string
}

variable "location" {
  description = "Azure region to deploy the resources"
  type        = string
  default     = "northeurope"
}

variable "cluster_name" {
  description = "Name of the AKS cluster"
  type        = string
}

variable "kubernetes_version" {
  description = "Kubernetes version"
  type        = string
  default     = "1.21.2"
}

variable "node_count" {
  description = "Number of nodes in the default node pool"
  type        = number
  default     = 2
}

variable "vm_size" {
  description = "Size of the VM for nodes"
  type        = string
  default     = "Standard_DS2_v2"
}

variable "environment" {
  description = "Environment name, used for tagging"
  type        = string
  default     = "Development"
}

variable "tags" {
  description = "A map of tags to add to all resources"
  type        = map(string)
  default     = {}
}

variable "acr_name" {
  description = "Name of the Azure Container Registry"
  type        = string
}