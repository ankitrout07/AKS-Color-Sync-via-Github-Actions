#!/bin/bash
echo "Waiting for LoadBalancer IPs..."
while [ -z "$COLOR_IP" ]; do
  COLOR_IP=$(kubectl get svc color-sync-service -o jsonpath='{.status.loadBalancer.ingress[0].ip}' 2>/dev/null)
  [ -z "$COLOR_IP" ] && sleep 5
done

while [ -z "$GRAFANA_IP" ]; do
  GRAFANA_IP=$(kubectl get svc monitoring-stack-grafana -n monitoring -o jsonpath='{.status.loadBalancer.ingress[0].ip}' 2>/dev/null)
  [ -z "$GRAFANA_IP" ] && sleep 5
done

echo "------------------------------------------------"
echo "PRODUCTION ENDPOINTS"
echo "------------------------------------------------"
echo "Color-Sync App: http://$COLOR_IP"
echo "Grafana Dash:   http://$GRAFANA_IP"
echo "------------------------------------------------"