# 🎨 Color-Sync CI/CD Pipeline

![Build Status](https://img.shields.io/github/actions/workflow/status/ankitrout07/Color-Sync-Github-Actions/deploy.yml?branch=main&style=for-the-badge)
![Docker](https://img.shields.io/badge/Docker-24.0.5-blue?style=for-the-badge&logo=docker)
![NodeJS](https://img.shields.io/badge/Node.js-20.x-green?style=for-the-badge&logo=node.js)
![Ubuntu](https://img.shields.io/badge/Ubuntu-24.04_LTS-orange?style=for-the-badge&logo=ubuntu)
![Kubernetes](https://img.shields.io/badge/Kubernetes-AKS-326CE5?style=for-the-badge&logo=kubernetes)

**Color-Sync** is a high-uptime, automated deployment pipeline designed to demonstrate seamless synchronization between source code and live infrastructure. This project serves as a foundational **Proof of Concept (PoC)** for a localized DevOps lifecycle, bridging the gap between a GitHub repository and a private Ubuntu environment.

---

## 🛠 Tech Stack

| Component | Technology |
| :--- | :--- |
| **Runtime** | Node.js 20.x (Express.js) |
| **K8s Client** | @kubernetes/client-node |
| **Containerization** | Docker |
| **Orchestration** | GitHub Actions (Custom Self-Hosted Runner) |
| **Cloud Kubernetes** | Azure Kubernetes Service (AKS) |
| **Container Registry** | Azure Container Registry (ACR) |
| **IaC** | Terraform (azurerm ~3.90) |
| **Infrastructure** | Ubuntu 24.04 LTS |
| **Frontend** | TailwindCSS + Live AKS Monitoring |

---

## 🏗 Architecture & Logic

This project implements a **Push-to-Deploy** strategy with **Live Observability**:

1. **Source Control:** Developer pushes changes to the `main` branch.
2. **Job Assignment:** GitHub Actions detects the push and assigns the job to the **Self-Hosted Runner**.
3. **Container & K8s Orchestration:**
   - The runner builds the image and pushes it to **Azure Container Registry (ACR)**.
   - It then triggers a `kubectl apply` to update the **AKS Cluster**.
4. **Live Dashboard:** The frontend automatically polls the backend, which queries the **Kubernetes API** to show real-time pod replication and health status.
5. **Health Check:** The pipeline performs a post-deployment validation using `kubectl rollout status`.

---

## 📁 Project Structure

```
Color-Sync-Github-Actions/
├── .github/workflows/deploy.yml   # GitHub Actions CI/CD pipeline
├── k8s/
│   ├── namespace.yaml             # Kubernetes namespace
│   ├── deployment.yaml            # Pod deployment (2 replicas)
│   ├── service.yaml               # LoadBalancer service
│   └── hpa.yaml                   # Horizontal Pod Autoscaler
├── terraform/
│   ├── providers.tf               # Terraform provider config (azurerm, random)
│   ├── variables.tf               # Input variables
│   ├── main.tf                    # AKS + ACR + Role Assignment resources
│   └── outputs.tf                 # Outputs: ACR URL, AKS name, kubectl command
├── scripts/
│   └── endpoints.sh               # Print AKS public endpoints
├── app.js                         # Express.js server
├── index.html                     # Frontend UI
├── Dockerfile                     # Container definition
├── .dockerignore                  # Docker build exclusions
├── .env.example                   # Environment variable template
└── how_to_run.md                  # Full usage guide
```

---

## ⚡ Key DevOps Features

* **Live AKS Pod Monitoring:** Real-time dashboard powered by `@kubernetes/client-node` to show actual pod health and replication status (desired vs. ready).
* **Automated AKS Deployment:** GitHub Actions pipeline that builds, pushes to ACR, and deploys to AKS in one flow.
* **AKS Ready:** Full Kubernetes manifests with namespace isolation and Horizontal Pod Autoscaling (2–5 replicas).
* **Infrastructure as Code:** Terraform provisions the full Azure stack (Resource Group, ACR, AKS) in one command.
* **Health Endpoint:** `/health` endpoint built into the app for readiness probes.
* **CI/CD Maturity:** Achieved **Zero-Manual-Intervention** deployment from Git Push to Live AKS URL.

---

## 📊 Project Roadmap (The 5-Project Series)

- [x] **Project 1: Color-Sync** (Localized CI/CD & Docker + AKS)
- [ ] **Project 2: Observability Stack** (Prometheus & Grafana Monitoring)

---

## 🚀 Getting Started

```bash
# Clone the repository
git clone https://github.com/ankitrout07/Color-Sync-Github-Actions.git
cd Color-Sync-Github-Actions

# Copy environment variables
cp .env.example .env

# Run locally with Node.js
npm install && node app.js
# Visit: http://localhost:3000

# OR run with Docker
docker build -t color-sync .
docker run -d -p 8081:3000 --name color-sync-app color-sync
# Visit: http://localhost:8081
```

For full setup including AKS deployment and shutdown steps, see **[how_to_run.md](./how_to_run.md)**.
