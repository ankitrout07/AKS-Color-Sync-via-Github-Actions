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
- The dashboard will show real-time pod status and replication counts fetched directly from the Kubernetes API.

### ⚡ Automated Deployment (CI/CD)
Once the infrastructure is provisioned, you no longer need to run manual `kubectl` commands. Every **Git Push** to `main` will:
1. Build the Docker image.
2. Push it to your ACR.
3. Automatically update the AKS deployment and service.
4. Verify the rollout status.

### Shutdown
```bash
# Remove all Kubernetes resources
kubectl delete -f k8s/

# Destroy all Azure infrastructure managed by Terraform
cd terraform
terraform destroy
```

---

kubectl create namespace color-sync
# Apply the Deployment to the color-sync namespace
kubectl apply -f k8s/deployment.yaml

# Apply the Service to the color-sync namespace
kubectl apply -f k8s/service.yaml

# Check the pods in the specific namespace
kubectl get pods -n color-sync

# Watch for the LoadBalancer Public IP in the namespace
kubectl get svc -n color-sync -w