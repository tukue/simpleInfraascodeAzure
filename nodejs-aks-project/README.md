# Node.js AKS Application

This project deploys a Node.js application to Azure Kubernetes Service (AKS) using Terraform for infrastructure provisioning.

## Prerequisites

- Azure CLI
- Terraform
- Docker
- kubectl

## Setup

1. Initialize Terraform:
   ```
   cd terraform
   terraform init
   ```

2. Apply Terraform configuration:
   ```
   terraform apply
   ```

3. Build and push Docker image:
   ```
   ./scripts/build.sh
   ```

4. Deploy to AKS:
   ```
   ./scripts/deploy.sh
   ```

