# 🎨 Color-Sync CI/CD Pipeline

![Build Status](https://img.shields.io/github/actions/workflow/status/ankitrout07/Color-Sync-Github-Actions/deploy.yml?branch=main&style=for-the-badge)
![Docker](https://img.shields.io/badge/Docker-24.0.5-blue?style=for-the-badge&logo=docker)
![NodeJS](https://img.shields.io/badge/Node.js-18.x-green?style=for-the-badge&logo=node.js)
![Ubuntu](https://img.shields.io/badge/Ubuntu-24.04_LTS-orange?style=for-the-badge&logo=ubuntu)

**Color-Sync** is a high-uptime, automated deployment pipeline designed to demonstrate seamless synchronization between source code and live infrastructure. This project serves as a foundational **Proof of Concept (PoC)** for a localized DevOps lifecycle, bridging the gap between a GitHub repository and a private Ubuntu environment.

---

## 🛠 Tech Stack

| Component | Technology |
| :--- | :--- |
| **Runtime** | Node.js (Express.js) |
| **Containerization** | Docker (Multi-stage build optimized) |
| **Orchestration** | GitHub Actions (Custom Self-Hosted Runner) |
| **Infrastructure** | Ubuntu 24.04 LTS (NTZ-LINUX-003) |
| **Frontend** | TailwindCSS + Glassmorphism UI |

---

## 🏗 Architecture & Logic



This project implements a **Push-to-Deploy** strategy:

1.  **Source Control:** Developer pushes changes to the `main` branch.
2.  **Job Assignment:** GitHub Actions detects the push and assigns the job to the **Self-Hosted Runner** on the local node.
3.  **Docker Orchestration:** * The runner pulls the latest source code.
    * Existing containers are forcefully removed (`docker rm -f`) to prevent port 8080 conflicts.
    * A fresh image is built to ensure environment parity.
    * The container is deployed with a `3000 -> 8080` port mapping.
4.  **Health Check:** The pipeline performs a post-deployment validation to ensure the service status is `Up`.

---

## ⚡ Key DevOps Features

* **Self-Hosted Infrastructure:** Optimized for cost-efficiency by leveraging local compute resources.
* **Automated Lifecycle:** Scripted cleanup of legacy images and containers to maintain 80GB storage health.
* **Modular UI:** A high-fidelity dashboard displaying real-time system status and build metadata.
* **CI/CD Maturity:** Achieved **Zero-Manual-Intervention** deployment from Git Push to Live URL.

---

## 📊 Project Roadmap (The 5-Project Series)

- [x] **Project 1: Color-Sync** (Localized CI/CD & Docker)
- [ ] **Project 2: Observability Stack** (Prometheus & Grafana Monitoring)


---

## 🚀 Getting Started

To view the live sync on your local environment:

```bash
# Clone the repository
git clone [https://github.com/ankitrout07/Color-Sync-Github-Actions.git](https://github.com/ankitrout07/Color-Sync-Github-Actions.git)

# Ensure Docker is running
docker ps

# Access the local endpoint
curl -I http://localhost:8080
