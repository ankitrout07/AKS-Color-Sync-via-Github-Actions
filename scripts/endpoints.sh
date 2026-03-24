#!/bin/bash

# 1. Fetch Cluster Context
CLUSTER_NAME="aks-colorsync"
RG_NAME="AK8S-REBUILD"
KUBE_API=$(kubectl cluster-info | grep 'Kubernetes control plane' | awk '{print $NF}')

echo "Waiting for Color-Sync LoadBalancer IP..."
while [ -z "$COLOR_IP" ]; do
  COLOR_IP=$(kubectl get svc color-sync-service -o jsonpath='{.status.loadBalancer.ingress[0].ip}' 2>/dev/null)
  if [ -z "$COLOR_IP" ]; then
    echo -n "."
    sleep 5
  fi
done

echo -e "\n------------------------------------------------"
echo "PRODUCTION ENDPOINTS: $CLUSTER_NAME"
echo "------------------------------------------------"
echo "Primary Application:  http://$COLOR_IP"
echo "Kubernetes API:       $KUBE_API"
echo "Azure Console:        https://portal.azure.com/#@/resource/subscriptions/$(az account show --query id -o tsv)/resourceGroups/$RG_NAME/providers/Microsoft.ContainerService/managedClusters/$CLUSTER_NAME/overview"
echo "------------------------------------------------"