# Color-Sync — How to Run

This guide covers how to **start**, **deploy to AKS**, and **shut down** the Color-Sync project.

---

## Method 1: Running Locally with Node.js

**Prerequisites:** Node.js 20.x and npm installed.

```bash
# 1. Copy environment variables
cp .env.example .env

# 2. Install dependencies
npm install

# 3. Start the app
node app.js
```

Visit: [http://localhost:3000](http://localhost:3000)

### Shutdown
```bash
# Press Ctrl+C in the terminal running the app
```

---

## Method 2: Running with Docker

**Prerequisites:** Docker installed and running.

```bash
# 1. Build the Docker image
docker build -t color-sync .

# 2. Run the container (host port 8081 → container port 3000)
docker run -d -p 8081:3000 --name color-sync-app color-sync
```

Visit: [http://localhost:8081](http://localhost:8081)

### Shutdown
```bash
# Stop and remove the container
docker stop color-sync-app
docker rm color-sync-app
```

---

## Method 3: Deploying to AKS (Azure Kubernetes Service)

**Prerequisites:** [Azure CLI](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli) and [kubectl](https://kubernetes.io/docs/tasks/tools/) installed.

```bash
# Set variables
RESOURCE_GROUP="AK8S-REBUILD"
CLUSTER_NAME="aks-colorsync"
ACR_NAME="acrcolorsyncankit2026"
LOCATION="eastus"
```

```bash
# 1. Create resource group
az group create --name $RESOURCE_GROUP --location $LOCATION

# 2. Create Azure Container Registry and push image
az acr create --resource-group $RESOURCE_GROUP --name $ACR_NAME --sku Basic
az acr build --registry $ACR_NAME --image color-sync:latest .

# 3. Create AKS cluster linked to ACR
az aks create \
  --resource-group $RESOURCE_GROUP \
  --name $CLUSTER_NAME \
  --node-count 2 \
  --generate-ssh-keys \
  --attach-acr $ACR_NAME

# 4. Connect kubectl to the cluster
az aks get-credentials --resource-group $RESOURCE_GROUP --name $CLUSTER_NAME

# 5. Apply the namespace first, then all manifests
kubectl apply -f k8s/namespace.yaml
kubectl apply -f k8s/

# 6. Get the public endpoint
bash scripts/endpoints.sh
```

Visit the **Primary Application** URL printed by the script.

> **Note:** The HPA (`k8s/hpa.yaml`) automatically scales pods between **2 and 5 replicas** based on CPU (>70%) and Memory (>80%) usage.

### Shutdown
```bash
# Remove all Kubernetes resources in the namespace
kubectl delete -f k8s/

# (Optional) Delete the entire AKS cluster and resource group
az group delete --name $RESOURCE_GROUP --yes --no-wait
```

---

## Method 4: Provision AKS Infrastructure with Terraform (Recommended)

**Prerequisites:** [Azure CLI](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli), [Terraform ≥ 1.3](https://developer.hashicorp.com/terraform/install), and [kubectl](https://kubernetes.io/docs/tasks/tools/) installed.

```bash
# 1. Authenticate to Azure
az login

# 2. Go to the terraform directory
cd terraform

# 3. Initialize Terraform (downloads providers)
terraform init

# 4. Preview the plan
terraform plan

# 5. Provision the infrastructure (Resource Group + ACR + AKS)
terraform apply
```

After `apply` completes, Terraform will print the outputs:

| Output | Description |
|---|---|
| `acr_login_server` | ACR URL to push your Docker image to |
| `aks_cluster_name` | Name of your AKS cluster |
| `aks_kube_config_command` | Run this to connect kubectl to your cluster |

```bash
# 6. Connect kubectl (use the exact command from terraform output)
az aks get-credentials --resource-group AK8S-REBUILD-TF --name aks-colorsync-tf

# 7. Push the Docker image to ACR
cd ..
az acr build --registry <acr_login_server from output> --image color-sync:latest .

# 8. Deploy to Kubernetes
kubectl apply -f k8s/namespace.yaml
kubectl apply -f k8s/

# 9. Get the public endpoint
bash scripts/endpoints.sh
```

### Shutdown
```bash
# Remove all Kubernetes resources
kubectl delete -f k8s/

# Destroy all Azure infrastructure managed by Terraform
cd terraform
terraform destroy
```

---

## 🔗 Useful Endpoints

| Endpoint | Description |
|---|---|
| `/` | Main Color-Sync UI |
| `/health` | Health check (returns `{"status":"ok"}`) |

---

> **Tip:** For CI/CD via GitHub Actions, simply push changes to the `main` branch — the self-hosted runner will automatically rebuild and redeploy the container using `--no-cache` to ensure your latest HTML changes are always picked up.
