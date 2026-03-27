# Color-Sync — How to Run

This guide covers how to **start**, **deploy to AKS**, and **shut down** the Color-Sync project.

## Method: Provision AKS Infrastructure with Terraform (Recommended)

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
# 6. Configure the Application for your Infrastructure
Before pushing, you need to update a few files with your new ACR name:
1. Run `terraform output acr_login_server`
2. Update `ACR_SERVER` in `.github/workflows/deploy.yml`
3. Update `image` in `k8s/deployment.yaml`

# 7. Connect kubectl (use the exact command from terraform output)
az aks get-credentials --resource-group YOUR_RG --name YOUR_AKS

# 8. Initial Push and Deploy
- Commit and push your changes to `main` — **Github Actions will now handle the build and deploy to AKS automatically!**
- Alternatively, for a manual push:
  `az acr build --registry <acr_login_server from output> --image color-sync:latest .`
  `kubectl apply -f k8s/`

# 9. Access the Live Dashboard
The dashboard is now "Live" and connected to your AKS cluster!
- Get the public endpoint: `bash scripts/endpoints.sh`
- Visit the URL in your browser.
- The dashboard shows real-time pod status and replication counts fetched directly from the Kubernetes API.

### ⚡ Automated Deployment (CI/CD)
This repository ships a workflow in `.github/workflows/deploy.yml` that performs full CI/CD on every `main` push.

What happens when you push to `main`:
1. Checkout code.
2. Login to Azure using `AZURE_CREDENTIALS` secret.
3. Run Terraform (`terraform init` + `terraform apply -auto-approve`) in `terraform/`.
4. Export ACR and AKS outputs.
5. Login to ACR and build/push image with git short SHA tag.
6. Connect to AKS and deploy the manifests.
7. Update `color-sync` deployment image, apply service and HPA.

### ✅ Required GitHub secrets
- `AZURE_CREDENTIALS` (service principal JSON)
- `AZURE_RESOURCE_GROUP`
- `AZURE_AKS_CLUSTER_NAME`

### Quick local workflow (if you want manual control)
```bash
# Provision infra
cd terraform
terraform init
terraform plan
terraform apply -auto-approve

# Connect kubectl
az aks get-credentials --resource-group $(terraform output -raw resource_group_name) --name $(terraform output -raw aks_cluster_name) --overwrite-existing

# Prepare Kubernetes resources
kubectl apply -f k8s/namespace.yaml
kubectl apply -f k8s/deployment.yaml
kubectl apply -f k8s/service.yaml
kubectl apply -f k8s/hpa.yaml

# Validate
kubectl get pods -n color-sync
kubectl get svc -n color-sync -w
```

### Cleanup
```bash
kubectl delete -f k8s/
cd terraform
terraform destroy -auto-approve
```
