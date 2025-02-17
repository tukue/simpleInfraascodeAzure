Node.js AKS Application

This project deploys a Node.js application to Azure Kubernetes Service (AKS) using Terraform for infrastructure provisioning.

Prerequisites
Azure CLI
Terraform
Docker
kubectl

Setup
Initialize Terraform: 
cd terraform
terraform init
Terraform configuration
terraform apply
kubernetes/: Contains Kubernetes manifests for deployment and service.
scripts/: Contains scripts for building the Docker image and deploying to AKS.
src/: Contains the Node.js application source code and Dockerfile.
terraform/: Contains Terraform configuration files for provisioning AKS and related resources. 


