#!/bin/bash

set -e

echo "🚀 Starting DevSecOps Lab Setup..."

# -----------------------------
# 1. Start Minikube
# -----------------------------
# echo "🔧 Starting Minikube..."
# minikube start --memory=8192 --cpus=4

# # Enable metrics server (needed for monitoring)
# minikube addons enable metrics-server

# -----------------------------
# 2. Add Helm Repositories
# -----------------------------
echo "📦 Adding Helm repositories..."
helm repo add sonarqube https://SonarSource.github.io/helm-chart-sonarqube
helm repo add kyverno https://kyverno.github.io/kyverno/
helm repo add falcosecurity https://falcosecurity.github.io/charts
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts

helm repo update

# -----------------------------
# 3. Install Kyverno
# -----------------------------
# echo "🔐 Installing Kyverno..."
# helm install kyverno kyverno/kyverno \
#   --namespace kyverno \
#   --create-namespace

# -----------------------------
# 4. Install Falco
# -----------------------------
echo "🛡️ Installing Falco..."
helm install falco falcosecurity/falco \
  --namespace falco \
  --create-namespace

# -----------------------------
# 5. Install SonarQube
# -----------------------------
echo "🔍 Installing SonarQube..."
helm install sonarqube sonarqube/sonarqube \
  --namespace sonarqube \
  --create-namespace \
  --set service.type=NodePort

# -----------------------------
# 6. Install Prometheus + Grafana
# -----------------------------
echo "📊 Installing Prometheus & Grafana..."
helm install monitoring prometheus-community/kube-prometheus-stack \
  --namespace monitoring \
  --create-namespace

# -----------------------------
# 7. Wait for Pods
# -----------------------------
echo "⏳ Waiting for all pods to be ready..."
kubectl wait --for=condition=ready pod --all --all-namespaces --timeout=600s

# -----------------------------
# 8. Access URLs
# -----------------------------
echo ""
echo "🎉 Setup Complete!"
echo ""

echo "📌 Access SonarQube:"
echo "kubectl port-forward svc/sonarqube 9000:9000 -n sonarqube"

echo ""
echo "📌 Access Grafana:"
echo "kubectl port-forward svc/monitoring-grafana 3000:80 -n monitoring"

echo ""
echo "📌 Default Grafana Credentials:"
echo "Username: admin"
echo "Password: prom-operator"

echo ""
echo "📌 Check Falco logs:"
echo "kubectl logs -n falco -l app.kubernetes.io/name=falco"

echo ""
echo "📌 Kyverno policies:"
echo "kubectl get cpol"

echo ""
echo "✅ DevSecOps lab is ready!"
