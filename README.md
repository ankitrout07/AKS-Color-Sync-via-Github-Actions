Color-Sync CI/CD
Color-Sync is a high-uptime, automated deployment pipeline designed to demonstrate the seamless synchronization between source code and live infrastructure. This project serves as a foundational "Proof of Concept" (PoC) for a localized DevOps lifecycle, bridging the gap between a GitHub repository and a private Ubuntu environment.

🛠 Tech Stack
Engine: Node.js (Express.js)

Containerization: Docker (Multi-stage build optimized)

Orchestration: GitHub Actions (Custom Self-Hosted Runner)

Infrastructure: Ubuntu 24.04 LTS

Frontend: TailwindCSS + Glassmorphism UI

🏗 Architecture & Logic
This project implements a Push-to-Deploy strategy:

Code Commit: Developer pushes changes to the main branch.

Workflow Trigger: GitHub Actions detects the push and assigns the job to a Self-Hosted Runner on the NTZ-LINUX-003 node.

Docker Orchestration: * The runner pulls the latest source code.

The existing container is forcefully removed to prevent port conflicts.

A fresh Docker image is built to ensure environment parity.

The new container is deployed with a 3000 -> 8080 port mapping.

Verification: The pipeline performs a post-deployment health check to ensure the service is Running and not Exited.

⚡ Key DevOps Features
Self-Hosted Runner: Bypasses cloud-cost constraints by using local infrastructure.

Automated Cleanup: Scripted removal of legacy containers during the deployment cycle.

Modular UI: A dashboard that displays real-time system status and build metadata.

Zero-Manual-Intervention: From code change to live site without touching the Ubuntu terminal.
