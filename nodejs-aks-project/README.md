# Node.js AKS Application

This project deploys a Node.js application to Azure Kubernetes Service (AKS) using Terraform for infrastructure provisioning.

## Prerequisites

- Azure CLI
- Terraform
- Docker
- kubectl
- PowerShell

## Setup

1. Create a `.env` file in the root directory with your Azure credentials:
   ```
   AZURE_SUBSCRIPTION_ID=your-subscription-id
   AZURE_TENANT_ID=your-tenant-id
   AZURE_CLIENT_ID=your-client-id
   AZURE_CLIENT_SECRET=your-client-secret
   resource_group_name=my-nodejs-aks-rg
   location=northeurope
   cluster_name=my-aks-cluster
   acr_name=mynodejsacr
   ```

2. Run Terraform using the PowerShell script:
   ```powershell
   # Initialize Terraform
   .\scripts\Set-TerraformEnv.ps1 init
   
   # Plan the deployment
   .\scripts\Set-TerraformEnv.ps1 plan
   
   # Apply the configuration
   .\scripts\Set-TerraformEnv.ps1 apply
   ```

3. Build and push Docker image:
   ```
   .\scripts\build.sh
   ```

4. Deploy to AKS:
   ```
   .\scripts\deploy.sh
   ```

## Testing the Infrastructure

To test the Terraform infrastructure:

1. Run the initialization:
   ```powershell
   .\scripts\Set-TerraformEnv.ps1 init
   ```

2. Validate the configuration:
   ```powershell
   .\scripts\Set-TerraformEnv.ps1 validate
   ```

3. Create a test plan:
   ```powershell
   .\scripts\Set-TerraformEnv.ps1 plan
   ```
