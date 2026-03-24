# 🎨 Color-Sync: Project Deep Dive

This document provides a comprehensive overview of the **Color-Sync** project, detailing its architecture, automation, and observability features.

## 🚀 The Core Vision
**Color-Sync** is a Proof of Concept (PoC) for a modern, automated DevOps lifecycle. It bridges the gap between source code on GitHub and a production-ready environment in **Azure Kubernetes Service (AKS)**.

---

## 🛠 1. The Application Layer
At its heart, the project is a **Node.js (Express)** web application.

*   **Live Observability Backend (`app.js`)**: Unlike static apps, this backend uses the `@kubernetes/client-node` library to talk directly to the AKS cluster. It exposes a `/api/cluster-status` endpoint that returns real-time data about pods, replicas, and cluster health.
*   **Premium Dashboard (`index.html`)**: A modern, glassmorphism-style UI built with **TailwindCSS**. It polls the backend every 5 seconds to provide a "live" pulse of the infrastructure without requiring manual dashboard refreshes.

---

## 🏗 2. The Infrastructure (IaC)
We use **Terraform** in the `terraform/` folder to manage the entire Azure ecosystem. This ensures the environment is reproducible and version-controlled.

*   **Azure Kubernetes Service (AKS)**: Provides the managed Kubernetes environment where our app lives.
*   **Azure Container Registry (ACR)**: A private, secure storage for our Docker images.
*   **Managed Identity & RBAC**: Terraform automatically assigns the `AcrPull` role to the AKS cluster so it can pull images from ACR securely without needing manual secrets.

---

## 📦 3. Kubernetes Orchestration (`k8s/`)
The `k8s/` folder contains the "blueprints" for how your application lives inside the cluster.

*   **Self-Healing (Deployment)**: Configured with **2 replicas** by default. If a pod crashes or a server fails, AKS automatically replaces it within seconds.
*   **Dynamic Scaling (HPA)**: The Horizontal Pod Autoscaler is configured to scale your app from **2 to 5 replicas** based on CPU/Memory usage (e.g., if CPU > 70%).
*   **Networking (Service)**: Requests a **LoadBalancer** from Azure, giving the project a public IP address and exposing your dashboard on port 80.

---

## ⚡ 4. The CI/CD Pipeline (GitHub Actions)
The `.github/workflows/deploy.yml` is the "engine" of the project. On every `git push` to the `main` branch, it executes:

1.  **Container Build**: Creates a new Docker image from the latest source code.
2.  **ACR Ship**: Tags and pushes the image to your private **Azure Container Registry**.
3.  **AKS Rollout**: Triggers a `kubectl apply` to update the cluster with the new image.
4.  **Health Verification**: Wait for `kubectl rollout status` to ensure the new version is "Ready" before finishing the job.

---

## 📊 Summary of Flow
1.  **Developer** pushes code to GitHub.
2.  **GitHub Actions** builds, pushes, and deploys the code.
3.  **AKS** hosts the containers and scales them automatically.
4.  **The Live Dashboard** queries the AKS API and shows you exactly what's happening.

**Color-Sync represents a "Push-to-Live" maturity model where infrastructure, code, and monitoring are seamlessly integrated.**
