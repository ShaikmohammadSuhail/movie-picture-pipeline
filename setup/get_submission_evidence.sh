#!/usr/bin/env bash
set -euo pipefail

frontend_hostname="$(kubectl get svc mp-frontend -o jsonpath='{.status.loadBalancer.ingress[0].hostname}')"
frontend_ip="$(kubectl get svc mp-frontend -o jsonpath='{.status.loadBalancer.ingress[0].ip}')"

if [[ -n "${frontend_hostname}" ]]; then
  frontend_url="http://${frontend_hostname}"
elif [[ -n "${frontend_ip}" ]]; then
  frontend_url="http://${frontend_ip}"
else
  frontend_url=""
fi

if [[ -n "${frontend_url}" ]]; then
  echo "Frontend public URL: ${frontend_url}"
  echo "Open this URL in a browser and capture the movie list screenshot."
else
  echo "Frontend LoadBalancer URL is not assigned yet."
fi

backend_hostname="$(kubectl get svc mp-backend -o jsonpath='{.status.loadBalancer.ingress[0].hostname}')"
backend_ip="$(kubectl get svc mp-backend -o jsonpath='{.status.loadBalancer.ingress[0].ip}')"

if [[ -n "${backend_hostname}" ]]; then
  backend_url="http://${backend_hostname}:5000"
elif [[ -n "${backend_ip}" ]]; then
  backend_url="http://${backend_ip}:5000"
else
  backend_url=""
fi

if [[ -n "${backend_url}" ]]; then
  echo
  echo "Backend public URL: ${backend_url}"
  echo "Open ${backend_url}/movies in a browser and capture the JSON screenshot."
  echo "Or run: curl ${backend_url}/movies"
else
  echo
  echo "Backend LoadBalancer URL is not assigned yet. You can use a port-forward:"
  echo "kubectl port-forward svc/mp-backend 5000:5000"
fi

echo
echo "Kubernetes overview for submission evidence:"
echo "kubectl get all"
