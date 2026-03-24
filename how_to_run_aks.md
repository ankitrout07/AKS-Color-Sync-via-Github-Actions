# How to Initiate AKS (Azure Kubernetes Service) for Color-Sync

This guide addresses how to deploy the **Color-Sync** project to Azure Kubernetes Service using the existing configurations found in your `k8s/` and `scripts/` directories.

## Prerequisites
- [Azure CLI (`az`)](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli) installed and authenticated (`az login`)
- [`kubectl`](https://kubernetes.io/docs/tasks/tools/) installed

---

## Step 1: Set Up Variables
Based on `scripts/endpoints.sh` and `k8s/deployment.yaml`, open your terminal and set these environment variables:
```bash
RESOURCE_GROUP="AK8S-REBUILD"
CLUSTER_NAME="aks-colorsync"
ACR_NAME="acrcolorsyncankit2026"
LOCATION="eastus" # You can adjust this if needed
```

## Step 2: Create a Resource Group
Create the resource group where all Azure resources will reside:
```bash
az group create --name $RESOURCE_GROUP --location $LOCATION
```

## Step 3: Set Up Azure Container Registry (ACR)
Your deployment uses an image hosted at `acrcolorsyncankit2026.azurecr.io`.
1. Create the container registry:
   ```bash
   az acr create --resource-group $RESOURCE_GROUP --name $ACR_NAME --sku Basic
   ```
2. Build and push your Docker image to ACR directly from the project root directory:
   ```bash
   az acr build --registry $ACR_NAME --image color-sync:latest .
   ```

## Step 4: Create the AKS Cluster
Provision the cluster and link it to your ACR so it can pull the newly built image:
```bash
az aks create \
  --resource-group $RESOURCE_GROUP \
  --name $CLUSTER_NAME \
  --node-count 2 \
  --generate-ssh-keys \
  --attach-acr $ACR_NAME
```

## Step 5: Connect `kubectl` to the Cluster
Retrieve the connection credentials for your new AKS cluster:
```bash
az aks get-credentials --resource-group $RESOURCE_GROUP --name $CLUSTER_NAME
```

## Step 6: Deploy to Kubernetes
Apply the Kubernetes manifests from the `k8s` directory:
```bash
kubectl apply -f k8s/
```
*(This deploys the pods from `deployment.yaml` and sets up the load balancer from `service.yaml`)*

## Step 7: Verify and Get the Endpoint
Run the existing script to automatically wait for the LoadBalancer Public IP to be assigned:
```bash
bash scripts/endpoints.sh
```

You will see output similar to:
```
------------------------------------------------
PRODUCTION ENDPOINTS: aks-colorsync
------------------------------------------------
Primary Application:  http://YOUR_PUBLIC_IP
Kubernetes API:       ...
...
```
Navigate to the "Primary Application" URL in your browser to see Color-Sync running on AKS!
