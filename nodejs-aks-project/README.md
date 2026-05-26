# Node.js on Azure Kubernetes Service (AKS) — Infrastructure as Code

[![Terraform](https://img.shields.io/badge/IaC-Terraform-844FBA?logo=terraform)](https://www.terraform.io/)
[![Azure](https://img.shields.io/badge/Cloud-Azure-0078D4?logo=microsoftazure)](https://azure.microsoft.com/)
[![Kubernetes](https://img.shields.io/badge/Orchestration-Kubernetes-326CE5?logo=kubernetes)](https://kubernetes.io/)
[![Node.js](https://img.shields.io/badge/Runtime-Node.js-339933?logo=nodedotjs)](https://nodejs.org/)
[![Docker](https://img.shields.io/badge/Container-Docker-2496ED?logo=docker)](https://www.docker.com/)

A fully automated **Infrastructure as Code** (IaC) project that provisions an **Azure Kubernetes Service (AKS)** cluster using **Terraform**, containerizes a **Node.js / Express** web application with **Docker**, and deploys it onto the cluster via **Kubernetes manifests**.

> **For recruiters:** This end-to-end project demonstrates cloud provisioning (Azure), infrastructure automation (Terraform), containerization (Docker), container orchestration (Kubernetes), and application development (Node.js) — all in one reproducible pipeline.
>
> **For engineers:** A clean reference architecture for deploying containerized workloads on Azure with repeatable Terraform-managed infrastructure and standard Kubernetes manifests.

---

## Architecture Overview

### High-Level Infrastructure

```mermaid
graph TB
    subgraph "🌐 Internet"
        User["User / Client"]
    end

    subgraph "☁️ Microsoft Azure"
        RG["Resource Group<br/><i>my-nodejs-aks-rg</i>"]
        
        subgraph "☸️ AKS Cluster<br/><i>my-aks-cluster</i>"
            direction TB
            NodePool["Node Pool<br/>3x Standard_DS2_v2 VMs"]
            
            subgraph "📦 Kubernetes Resources"
                Service["LoadBalancer Service<br/><i>nodejs-app-service</i><br/>Port 80 → 3000"]
                Deployment["Deployment<br/><i>nodejs-app</i><br/>3 replicas"]
                Pod1["Pod 1<br/>nodejs-app:latest"]
                Pod2["Pod 2<br/>nodejs-app:latest"]
                Pod3["Pod 3<br/>nodejs-app:latest"]
            end
        end

        ACR["Azure Container Registry<br/>(optional external registry)"]
    end

    User -->|"HTTP :80"| Service
    Service --> Deployment
    Deployment --> Pod1 & Pod2 & Pod3
    Pod1 -.->|"pulls image"| ACR
    Pod2 -.->|"pulls image"| ACR
    Pod3 -.->|"pulls image"| ACR
    RG --> AKS
```

### Deployment Pipeline

```mermaid
graph LR
    subgraph "1️⃣ Provision Infrastructure"
        direction TB
        TF1["terraform init"] --> TF2["terraform apply"]
        TF2 --> AKS["AKS Cluster<br/>+ Resource Group"]
    end

    subgraph "2️⃣ Build & Push Container"
        direction TB
        Build["docker build<br/>Node.js 14 + Express"] --> Tag["docker tag"] --> Push["docker push<br/>to registry"]
    end

    subgraph "3️⃣ Deploy to Kubernetes"
        direction TB
        K1["kubectl apply<br/>deployment.yaml"] --> K2["kubectl apply<br/>service.yaml"] --> K3["LoadBalancer<br/>public IP assigned"]
    end

    TF1 --> Build
    Push --> K1
    AKS -.->|"kubeconfig<br/>credentials"| K1

    style TF1 fill:#844FBA,color:#fff
    style TF2 fill:#844FBA,color:#fff
    style Build fill:#2496ED,color:#fff
    style Push fill:#2496ED,color:#fff
    style K1 fill:#326CE5,color:#fff
    style K2 fill:#326CE5,color:#fff
    style K3 fill:#326CE5,color:#fff
```

### Project Structure

```mermaid
graph TD
    Root["📁 nodejs-aks-project"]
    
    Root --> Src["📁 src/"]
    Root --> TF["📁 terraform/"]
    Root --> K8s["📁 kubernetes/"]
    Root --> Scripts["📁 scripts/"]
    Root --> Readme["📄 README.md"]

    Src --> AppJS["app.js<br/>Express routes: / /about /users"]
    Src --> Package["package.json<br/>express ^4.17.1"]
    Src --> Dockerfile["Dockerfile<br/>node:14 → expose 4000"]

    TF --> Main["main.tf<br/>AKS + Resource Group"]
    TF --> Vars["variables.tf<br/>cluster_name, node_count, vm_size, ..."]
    TF --> Outputs["outputs.tf<br/>kube_config, cluster_id, host"]
    TF --> TFVars["terraform.tfvars<br/>my-aks-cluster, 3 nodes, northeurope"]

    K8s --> Deploy["deployment.yaml<br/>3 replicas, image:latest"]
    K8s --> Service["service.yaml<br/>LoadBalancer :80 → :3000"]

    Scripts --> BuildSH["build.sh<br/>docker build + push"]
    Scripts --> DeploySH["deploy.sh<br/>kubectl apply + rollout"]
```

---

## Technology Stack

| Layer | Technology | Purpose |
|---|---|---|
| **Cloud Provider** | Microsoft Azure | Infrastructure hosting |
| **IaC** | Terraform (HCL) | Provision AKS cluster & resource group |
| **Container Runtime** | Docker | Package Node.js app into image |
| **Orchestration** | Kubernetes | Manage containers (Deployment & Service) |
| **Application** | Node.js 14 / Express.js | Simple REST API server |
| **Automation** | Bash | Build & deploy scripts |

---

## Prerequisites

| Tool | Version | Purpose |
|---|---|---|
| [Azure CLI](https://docs.microsoft.com/cli/azure/install-azure-cli) | Latest | Authenticate with Azure |
| [Terraform](https://www.terraform.io/downloads) | >= 1.0 | Provision cloud resources |
| [Docker](https://docs.docker.com/get-docker/) | Latest | Build container images |
| [kubectl](https://kubernetes.io/docs/tasks/tools/) | >= 1.21 | Manage Kubernetes cluster |

You also need an **active Azure subscription** with sufficient quotas for AKS (3 x Standard_DS2_v2 VMs by default).

---

## Quick Start

```bash
# 1. Clone the repository
git clone <repo-url>
cd nodejs-aks-project

# 2. Authenticate with Azure
az login

# 3. Provision AKS infrastructure
cd terraform
terraform init
terraform apply   # ⚠️ Review changes before confirming
cd ..

# 4. Configure kubectl to connect to the new cluster
az aks get-credentials --resource-group my-nodejs-aks-rg --name my-aks-cluster

# 5. Build and push the Docker image
#    🔧 First update IMAGE_NAME in scripts/build.sh to your registry
./scripts/build.sh

# 6. Deploy the application to AKS
#    🔧 First update variables in scripts/deploy.sh
./scripts/deploy.sh

# 7. Get the public IP
kubectl get service nodejs-app-service
```

---

## Detailed Walkthrough

### 1. Infrastructure Provisioning (`terraform/`)

The Terraform configuration provisions:

- **Resource Group** — Logical container for all Azure resources
- **AKS Cluster** — Managed Kubernetes with:
  - 3 worker nodes (Standard_DS2_v2)
  - Azure CNI networking with Calico network policies
  - System-assigned managed identity
  - Configurable Kubernetes version, node count, and VM size

Key outputs (marked `sensitive` for security):
- `kube_config` — Cluster access credentials
- `host` — API server endpoint
- `client_certificate` — Authentication certificate

### 2. Application (`src/`)

A minimal Express.js server on **port 4000** with three endpoints:

| Route | Response |
|---|---|
| `GET /` | `"Hello from Node.js on AKS!"` |
| `GET /about` | `"This is a simple Node.js app running on AKS."` |
| `GET /users` | `"User list would be displayed here."` |

The **Dockerfile** uses `node:14` base image, installs npm dependencies, and exposes port 4000.

### 3. Kubernetes Deployment (`kubernetes/`)

| Resource | Type | Details |
|---|---|---|
| **Deployment** | `apps/v1` | 3 replicas, rolling update, image `${ACR_NAME}.azurecr.io/nodejs-app:latest` |
| **Service** | `v1` | Type `LoadBalancer`, maps port 80 → container port 3000 |

### 4. Automation Scripts (`scripts/`)

- **`build.sh`** — Builds the Docker image, tags it with the short git commit hash and `latest`, then pushes to your container registry
- **`deploy.sh`** — Creates a namespace (if needed), applies Deployment and Service manifests via `kubectl apply`, then waits for the rollout to complete

---

## Customization

### Variables (`terraform/terraform.tfvars`)

```hcl
resource_group_name = "my-nodejs-aks-rg"
location            = "northeurope"
cluster_name        = "my-aks-cluster"
node_count          = 3
vm_size             = "Standard_DS2_v2"
```

Adjust these to match your requirements (e.g., `node_count = 5` for higher availability).

### Port Configuration

The application listens on **port 4000** (`src/app.js`). If you change this, update:
1. `kubernetes/deployment.yaml` → `containerPort`
2. `kubernetes/service.yaml` → `targetPort`

---

## Clean Up

```bash
cd terraform
terraform destroy
```

This removes **all** Azure resources (resource group, AKS cluster, networking) to avoid ongoing costs.

---

## What This Project Demonstrates

- **Infrastructure as Code** — Entire Azure environment defined declaratively in Terraform
- **Containerization** — Node.js application packaged into a reproducible Docker image
- **Kubernetes Orchestration** — Deployment management (replicas, rolling updates) and service exposure via LoadBalancer
- **CI/CD Ready** — Scripted build and deploy pipeline, easily integrable with GitHub Actions, Azure DevOps, or Jenkins
- **Cloud-Native Patterns** — Managed Kubernetes, system-assigned identity, Azure CNI networking

---

## License

[MIT](../LICENSE)
