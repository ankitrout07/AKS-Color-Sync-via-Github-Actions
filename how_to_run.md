# Color-Sync — How to Run

This guide covers how to **start**, **deploy to AKS**, and **shut down** the Color-Sync project.

---

## Method 1: Running Locally with Node.js

**Prerequisites:** Node.js and npm installed.

```bash
# 1. Install dependencies
npm install

# 2. Start the app
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

# 2. Run the container
docker run -d -p 3000:3000 --name color-sync-app color-sync
```

Visit: [http://localhost:3000](http://localhost:3000)

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

# 5. Deploy to Kubernetes
kubectl apply -f k8s/

# 6. Get the public endpoint
bash scripts/endpoints.sh
```

Visit the **Primary Application** URL printed by the script.

### Shutdown
```bash
# Remove Kubernetes deployments
kubectl delete -f k8s/

# (Optional) Delete the entire AKS cluster and resource group
az group delete --name $RESOURCE_GROUP --yes --no-wait
```

---

> **Tip:** For CI/CD via GitHub Actions, simply push changes to the `main` branch — the self-hosted runner will automatically rebuild and redeploy the container.
