# Color-Sync: Project Deep Dive

This document provides a **meticulous** breakdown of the **Color-Sync** project, detailing every component from infrastructure to application logic and CI/CD automation.

---

## 1. Architecture Overview
**Color-Sync** is a high-uptime, automated deployment pipeline that bridges the gap between local development and cloud-native infrastructure in **Azure Kubernetes Service (AKS)**.

**The Workflow:**
1.  **Git Push**: A developer pushes code to the `main` branch.
2.  **GitHub Actions**: A self-hosted runner triggers the CI/CD pipeline.
3.  **Containerization**: The runner builds a Docker image and pushes it to **Azure Container Registry (ACR)**.
4.  **Orchestration**: The runner updates the **AKS Cluster** with the new image.
5.  **Live Observability**: The application backend queries the Kubernetes API directly to provide real-time status to the frontend dashboard.

---

## 🛠 2. The Application Layer

### Backend: Live Observability (`app.js`)
The backend is a **Node.js (Express)** application designed for cluster-aware monitoring.

*   **Kubernetes Client Integration**: Uses `@kubernetes/client-node` to authenticate and interact with the cluster.
    *   `kc.loadFromDefault()`: Loads the internal service account token when running inside the cluster.
    *   `CoreV1Api`: Used to list and monitor individual **Pods**.
    *   `AppsV1Api`: Used to read **Deployment** status (desired vs. ready replicas).
*   **API Endpoints**:
    *   `/api/cluster-status`: The heart of the app. It returns a JSON object containing pod names, phases, restart counts, and deployment replica stats.
    *   `/health`: A standard endpoint for Kubernetes **Readiness Probes** to ensure traffic only flows to healthy containers.

### Frontend: Premium Dashboard (`index.html`)
A modern, single-page dashboard built for visual clarity and real-time updates.

*   **Design System**: Styled with **TailwindCSS** using a "Glassmorphism" aesthetic (blurred backgrounds, subtle borders, and glowing accents).
*   **Live Polling**: A JavaScript `setInterval` fetches data from `/api/cluster-status` every **5 seconds**.
*   **Dynamic UI**:
    *   **Resource Visualization**: Progress bars represent the health percentage of pods and ready replicas.
    *   **Live Pipeline Stream**: A simulated terminal window shows recent deployment and system logs.
    *   **Status Indicators**: Glowing dots and color-coded labels (Healthy, Syncing, Error) provide instant feedback.

---

## 3. Infrastructure as Code (`terraform/`)
We use **Terraform** to provision a reproducible and secure Azure environment.

*   **Resource Group**: A logical container for all project resources (`azurerm_resource_group`).
*   **Azure Kubernetes Service (AKS)**:
    *   **System-Assigned Identity**: Enables the cluster to interact with other Azure services securely.
    *   **Default Node Pool**: Runs on burstable `Standard_B2s_v2` VMs (optimized for cost and Azure Student quotas).
*   **Azure Container Registry (ACR)**: A private registry for our Docker images.
*   **Security (RBAC)**: `azurerm_role_assignment` grants the AKS Kubelet the `AcrPull` role so it can pull images from ACR without needing hardcoded credentials.

---

## 4. Kubernetes Orchestration (`k8s/`)
The `k8s/` manifests define the desired state of the application.

*   **Namespace (`namespace.yaml`)**: Isolates project resources in a dedicated `color-sync` namespace.
*   **Deployment (`deployment.yaml`)**:
    *   **Replica Strategy**: Maintains **2 replicas** for high availability.
    *   **Resource Limits**: Restricts CPU (200m) and Memory (256Mi) to prevent noisy neighbors and ensure performance.
    *   **Probes**: Uses a `readinessProbe` to verify the app is ready to serve traffic.
*   **Autoscaling (`hpa.yaml`)**: The Horizontal Pod Autoscaler dynamically scales the app from **2 up to 5 pods** based on CPU/Memory utilization (targets 70-80%).
*   **Networking (`service.yaml`)**: A `LoadBalancer` type service that requests a Public IP from Azure, exposing the dashboard on port 80.

---

## ⚡ 5. The CI/CD Pipeline (`.github/workflows/deploy.yml`)
The engine of the project, executing the following on every push:

1.  **Checkout**: Pulls the latest source code.
2.  **Build**: Creates a Docker image using the `Dockerfile` (based on `node:20-slim` for efficiency).
3.  **Ship**: Tags the image with the ACR server URL and pushes it to the private registry.
4.  **Deploy**: Runs `kubectl apply` for all manifests.
5.  **Rollout Status**: Monitors the deployment until it is fully "Ready" and reports success or failure.

---

## Summary
**Color-Sync** represents a "Push-to-Live" maturity model where infrastructure, code, and monitoring are seamlessly integrated. It showcases how a small application can be scaled and monitored like a professional enterprise system.
