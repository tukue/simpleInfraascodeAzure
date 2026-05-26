# Node.js on Azure Kubernetes Service (AKS) — Infrastructure as Code

[![Terraform](https://img.shields.io/badge/IaC-Terraform-844FBA?logo=terraform)](https://www.terraform.io/)
[![Azure](https://img.shields.io/badge/Cloud-Azure-0078D4?logo=microsoftazure)](https://azure.microsoft.com/)
[![Kubernetes](https://img.shields.io/badge/Orchestration-Kubernetes-326CE5?logo=kubernetes)](https://kubernetes.io/)
[![Node.js](https://img.shields.io/badge/Runtime-Node.js-339933?logo=nodedotjs)](https://nodejs.org/)
[![Docker](https://img.shields.io/badge/Container-Docker-2496ED?logo=docker)](https://www.docker.com/)

An end-to-end **Infrastructure as Code** project that provisions an **Azure Kubernetes Service (AKS)** cluster via **Terraform**, containerizes a **Node.js (Express)** web server with **Docker**, and deploys it using **Kubernetes** manifests — all automated through shell scripts.

---

## 📋 Table of Contents

- [For Recruiters](#-for-recruiters)
- [For Engineers](#-for-engineers)
- [Architecture](#-architecture)
- [Quick Start](#-quick-start)
- [Detailed Walkthrough](#-detailed-walkthrough)
- [Customization](#-customization)
- [Clean Up](#-clean-up)

---

## 🔍 For Recruiters

> **Why this project matters:** It demonstrates every layer of a modern cloud-native deployment pipeline — from infrastructure provisioning to running application code — using the tools and practices that power real-world DevOps workflows.

### Skills Demonstrated

| Skill | How It's Applied |
|---|---|
| **Infrastructure as Code (IaC)** | Entire Azure environment defined in Terraform — repeatable, version-controlled, and destroyable |
| **Cloud Engineering (Azure)** | Provisioned AKS cluster, resource groups, networking (Azure CNI + Calico) |
| **Containerization** | Dockerized a Node.js app with a multi-stage build |
| **Container Orchestration** | Kubernetes Deployment (3 replicas) + LoadBalancer Service exposed to the internet |
| **DevOps / Automation** | Shell scripts automate the full build, push, and deploy cycle — CI/CD-ready |
| **Backend Development** | Express.js REST API with multiple routes |
| **Security Best Practices** | Sensible defaults: managed identity, sensitive output masking, Calico network policies |

### Technology Stack at a Glance

```
Cloud      →  Microsoft Azure (AKS)
Provision  →  Terraform (HCL)
Container  →  Docker
Orchestrate → Kubernetes
Code       →  Node.js / Express.js (port 4000)
Automate   →  Bash scripts
```

This project proves hands-on capability across the full **DevOps → Cloud → Backend** stack — exactly what cloud-native and platform engineering teams look for.

---

## 🛠️ For Engineers

A clean, minimal reference architecture for deploying containerized workloads on Azure. Everything is declarative, scripted, and ready to run.

### Design Decisions

| Choice | Rationale |
|---|---|
| **Terraform over ARM/Bicep** | Cloud-agnostic IaC; portable to AWS/GCP |
| **AKS with Azure CNI** | Native Azure networking; Calico for network policies |
| **System-assigned identity** | No manual secret management for cluster auth |
| **3 replicas** | Balance between availability and cost |
| **Standard_DS2_v2 nodes** | General-purpose burstable VMs — cost-effective for dev/test |
| **Shell scripts over CI config** | Keeps pipeline agnostic — drop into GitHub Actions, GitLab CI, or Azure DevOps |

### Prerequisites

| Tool | Min Version | Why |
|---|---|---|
| [Azure CLI](https://docs.microsoft.com/cli/azure/install-azure-cli) | Latest | `az login` + `az aks get-credentials` |
| [Terraform](https://www.terraform.io/downloads) | >= 1.0 | `terraform init` / `apply` / `destroy` |
| [Docker](https://docs.docker.com/get-docker/) | Latest | `docker build` / `push` |
| [kubectl](https://kubernetes.io/docs/tasks/tools/) | >= 1.21 | `kubectl apply` / `get service` |

Plus an **active Azure subscription** with quota for 3 x Standard_DS2_v2 VMs (12 vCPUs, 21 GiB RAM total).

---

## 📐 Architecture

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
    end

    User -->|"HTTP :80"| Service
    Service --> Deployment
    Deployment --> Pod1 & Pod2 & Pod3
    Pod1 -.->|"pulls image"| DockerRegistry["Container Registry<br/>(Docker Hub / ACR)"]
    Pod2 -.->|"pulls image"| DockerRegistry
    Pod3 -.->|"pulls image"| DockerRegistry
    RG --> AKS
```

### Deployment Pipeline

```mermaid
graph LR
    subgraph "1️⃣ Provision Infrastructure"
        direction TB
        TF1["terraform init"] --> TF2["terraform apply"]
        TF2 --> AKS["AKS Cluster + Resource Group"]
    end

    subgraph "2️⃣ Build & Push Container"
        direction TB
        Build["docker build<br/>Node.js 14 + Express"] --> Tag["docker tag"] --> Push["docker push<br/>to registry"]
    end

    subgraph "3️⃣ Deploy to Kubernetes"
        direction TB
        K1["kubectl apply<br/>deployment.yaml"] --> K2["kubectl apply<br/>service.yaml"] --> K3["LoadBalancer<br/>public IP assigned"]
    end

    AKS -.->|"kubeconfig credentials"| K1
    Push --> K1

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
    Root["📁 nodejs-aks-project/"]
    Root --> Src["📁 src/"]
    Root --> TF["📁 terraform/"]
    Root --> K8s["📁 kubernetes/"]
    Root --> Scripts["📁 scripts/"]

    Src --> AppJS["app.js — Express server (3 routes, port 4000)"]
    Src --> Package["package.json — express ^4.17.1"]
    Src --> Dockerfile["Dockerfile — node:14 base, expose 4000"]

    TF --> Main["main.tf — AKS cluster + resource group"]
    TF --> Vars["variables.tf — 7 configurable inputs"]
    TF --> Outputs["outputs.tf — kube_config, host, cluster_id"]
    TF --> TFVars["terraform.tfvars — default values"]

    K8s --> Deploy["deployment.yaml — 3 replicas, rolling update"]
    K8s --> Service["service.yaml — LoadBalancer :80 → :3000"]

    Scripts --> BuildSH["build.sh — docker build / tag / push"]
    Scripts --> DeploySH["deploy.sh — kubectl apply / rollout status"]
```

---

## 🚀 Quick Start

```bash
# 1. Authenticate with Azure
az login

# 2. Provision the AKS infrastructure
cd terraform
terraform init
terraform apply    # Review plan before confirming
cd ..

# 3. Connect kubectl to the new cluster
az aks get-credentials --resource-group my-nodejs-aks-rg --name my-aks-cluster

# 4. Build & push the Docker image
#    ⚠️ Edit IMAGE_NAME in scripts/build.sh to point to your registry first
./scripts/build.sh

# 5. Deploy to AKS
#    ⚠️ Edit variables in scripts/deploy.sh first
./scripts/deploy.sh

# 6. Get the public LoadBalancer IP
kubectl get service nodejs-app-service
```

---

## 🔧 Detailed Walkthrough

### 1. Terraform (`terraform/`)

Provisions two Azure resources:

- **`azurerm_resource_group`** — Logical container (`my-nodejs-aks-rg` in `northeurope`)
- **`azurerm_kubernetes_cluster`** — Managed Kubernetes with:
  - Default node pool: 3x `Standard_DS2_v2`
  - Azure CNI + Calico network policies
  - System-assigned managed identity
  - Configurable tags for environment tracking

**Sensitive outputs** (not shown in logs): `kube_config`, `host`, `client_certificate`.

### 2. Application (`src/`)

A minimal Express.js server listening on **port 4000**:

| Endpoint | Response |
|---|---|
| `GET /` | `"Hello from Node.js on AKS!"` |
| `GET /about` | `"This is a simple Node.js app running on AKS."` |
| `GET /users` | `"User list would be displayed here."` |

The **Dockerfile** uses `node:14`, installs dependencies via `npm install`, and exposes port 4000.

### 3. Kubernetes (`kubernetes/`)

| Manifest | Type | Key Details |
|---|---|---|
| `deployment.yaml` | `apps/v1` | 3 replicas; image `${ACR_NAME}.azurecr.io/nodejs-app:latest` |
| `service.yaml` | `v1` | Type `LoadBalancer`; port 80 → `targetPort: 3000` |

### 4. Scripts (`scripts/`)

- **`build.sh`** — Builds the image, tags it with the short git commit hash and `latest`, pushes to your registry
- **`deploy.sh`** — Creates a namespace (optional), applies Deployment + Service manifests inline, waits for rollout

---

## ⚙️ Customization

### Terraform Variables (`terraform/terraform.tfvars`)

```hcl
resource_group_name = "my-nodejs-aks-rg"
location            = "northeurope"
cluster_name        = "my-aks-cluster"
node_count          = 3
vm_size             = "Standard_DS2_v2"
```

All 7 variables are defined in `variables.tf` with defaults and descriptions.

### Changing the Application Port

The app listens on **port 4000** (`src/app.js`). If you change it, also update:

1. `kubernetes/deployment.yaml` — `containerPort`
2. `kubernetes/service.yaml` — `targetPort`

### Container Registry

The build script pushes to Docker Hub by default. For **Azure Container Registry**, set `ACR_NAME` in your environment and reference it in both scripts and manifests.

---

## 🧹 Clean Up

```bash
cd terraform
terraform destroy
```

Destroys the resource group, AKS cluster, and all associated networking — no orphaned resources, no ongoing costs.

---

## ✅ What This Project Demonstrates

- **Infrastructure as Code** — Declarative Azure environment in Terraform
- **Containerization** — Node.js app packaged into a portable Docker image
- **Kubernetes** — Deployments (replicas, rolling updates) + LoadBalancer Services
- **Automation** — Scripted build → push → deploy pipeline, ready for CI/CD
- **Cloud-Native Security** — Managed identity, sensitive output handling, Calico policies

---

## 📄 License

[MIT](../LICENSE)
