#!/bin/bash

# Script to add a new application to the homelab
# Usage: ./scripts/add-app.sh <app-name>
# Example: ./scripts/add-app.sh grafana

set -e

APP_NAME=$1

if [ -z "$APP_NAME" ]; then
    echo "Usage: $0 <app-name>"
    echo "Example: $0 grafana"
    exit 1
fi

echo "Adding new application: $APP_NAME"

# Create directories if they don't exist
mkdir -p "apps/$APP_NAME"
mkdir -p "environments"
mkdir -p "argocd/apps"

# Create ArgoCD application manifest from template
sed "s/<app-name>/$APP_NAME/g" \
    argocd/apps/_template.yaml > "argocd/apps/$APP_NAME.yaml"

echo "Created ArgoCD application: argocd/apps/$APP_NAME.yaml"

# Create basic Helm chart if it doesn't exist
if [ ! -f "apps/$APP_NAME/Chart.yaml" ]; then
    echo "Creating basic Helm chart structure for $APP_NAME..."
    helm create "apps/$APP_NAME"
    rm -rf "apps/$APP_NAME/templates/tests"
    echo "Created Helm chart: apps/$APP_NAME/"
fi

# Create environment values file template
if [ ! -f "environments/$APP_NAME-values.yaml" ]; then
    cat > "environments/$APP_NAME-values.yaml" << EOF
# Production values for $APP_NAME
# Customize these values for your production environment

# Basic configuration
replicaCount: 1

# Image configuration
image:
  repository: # Set your image repository
  tag: # Set your image tag
  pullPolicy: IfNotPresent

# Service configuration
service:
  type: ClusterIP
  port: 80

# Ingress configuration
ingress:
  enabled: false
  className: "nginx"
  annotations: {}
  hosts:
    - host: $APP_NAME.yourdomain.com
      paths:
        - path: /
          pathType: ImplementationSpecific
  tls:
    - secretName: $APP_NAME-tls
      hosts:
        - $APP_NAME.yourdomain.com

# Resources
resources:
  limits:
    cpu: 500m
    memory: 512Mi
  requests:
    cpu: 100m
    memory: 256Mi

# Environment variables
env: []

# Add your custom configuration here
EOF
    echo "Created values file: environments/$APP_NAME-values.yaml"
fi

echo ""
echo "✅ Application $APP_NAME has been set up!"
echo ""
echo "Next steps:"
echo "1. Customize the Helm chart in: apps/$APP_NAME/"
echo "2. Update values in: environments/$APP_NAME-values.yaml"
echo "3. Commit and push changes to Git"
echo "4. ArgoCD will automatically pick up the new application"
echo ""
echo "To test locally:"
echo "  helm template $APP_NAME ./apps/$APP_NAME -f ./environments/$APP_NAME-values.yaml"
