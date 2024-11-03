resource_group_name = "my-nodejs-aks-rg"
location            = "northeurope" 
cluster_name        = "my-aks-cluster"
node_count          = 3
vm_size             = "Standard_DS2_v2"
acr_name            = "mynodejsacr"

variable "location" {
  description = "Azure region where resources will be deployed"
  type        = string
  default     = "eu-west"       # Change this to your desired Azure region
}