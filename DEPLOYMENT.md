# Deployment Guide for Homelab Helm Charts

This repository contains an umbrella Helm chart for homelab applications, designed to work with ArgoCD for GitOps deployment.

## Repository Structure

```
homelab-helm-charts/
├── apps/                           # Helm charts
│   └── open-webui/                 # Open WebUI chart
│       ├── Chart.yaml
│       ├── values.yaml
│       ├── values-example.yaml
│       └── templates/
├── environments/                   # Application values
│   └── open-webui-values.yaml     # Open WebUI production values
├── argocd/                        # ArgoCD configurations
│   ├── homelab-apps.yaml          # Master "App of Apps" application
│   └── apps/                      # Individual application manifests
│       ├── _template.yaml         # Template for new apps
│       └── open-webui.yaml        # Open WebUI application
├── scripts/
│   └── add-app.sh                 # Script to add new applications
└── DEPLOYMENT.md                  # This file
```

## Prerequisites

1. **Kubernetes cluster** with ArgoCD installed
2. **Helm 3.x** for local testing
3. **Git repository** (GitHub/GitLab) for GitOps
4. **Ingress controller** (nginx recommended)
5. **Cert-manager** (for production TLS)

## Testing Locally

Before deploying with ArgoCD, test your charts locally:

### 1. Test Chart Rendering

```bash
# Test with default values
helm template open-webui ./apps/open-webui

# Test with production values
helm template open-webui ./apps/open-webui -f ./environments/open-webui-values.yaml

# Validate the chart
helm lint ./apps/open-webui
```

### 2. Dry Run Installation

```bash
# Test installation without actually deploying
helm install open-webui-test ./apps/open-webui \
  -f ./environments/open-webui-values.yaml \
  --dry-run --debug
```

### 3. Local Development Installation

```bash
# Install to local cluster for testing
helm install open-webui ./apps/open-webui \
  -f ./environments/open-webui-values.yaml \
  --namespace open-webui \
  --create-namespace
```

## ArgoCD Deployment (App of Apps Pattern)

This repository uses the **App of Apps** pattern, where one master ArgoCD application manages all your individual applications. This provides:

- ✅ **Single point of management** - Deploy one app to manage all apps
- ✅ **Scalability** - Easy to add new applications
- ✅ **Consistency** - All apps follow the same patterns
- ✅ **Simplified operations** - One command deploys everything

### 1. Prepare Repository

1. **Update repository URL** in the master application:

   ```yaml
   # In argocd/homelab-apps.yaml
   source:
     repoURL: https://github.com/nezdemkovski/homelab-helm-charts.git
   ```

2. **Customize application values**:

   - Update `environments/open-webui-values.yaml`
   - Set proper hostnames, storage classes, etc.

3. **Commit and push** changes to your Git repository

### 2. Deploy Master Application

**One command deploys all your applications:**

```bash
# Deploy the master "App of Apps" application
kubectl apply -f argocd/homelab-apps.yaml

# Check master application status
argocd app get homelab-apps

# This will automatically create and sync all individual applications
argocd app list
```

### 3. Monitor All Applications

```bash
# View all applications managed by the master app
argocd app list

# Get details of specific application
argocd app get open-webui

# Sync specific application if needed
argocd app sync open-webui
```

### 3. Monitor Deployment

```bash
# Watch ArgoCD application status
argocd app get open-webui --watch

# Check pods in the namespace
kubectl get pods -n open-webui

# Check application logs
kubectl logs -f deployment/open-webui -n open-webui
```

## Production Configuration

Your applications are configured for production deployment with:

- **Namespace**: `open-webui` (and `<app-name>` for other apps)
- **Ingress**: `open-webui.yourdomain.com` (with TLS)
- **Authentication**: Enabled for Open WebUI
- **Resources**: Production-grade (1000m CPU, 1Gi RAM)
- **Storage**: 10Gi with fast SSD storage class
- **Sync**: Manual approval required for safety
- **High Availability**: 2+ replicas with anti-affinity rules

## Customization

### Adding New Applications

Use the provided script to easily add new applications:

```bash
# Add a new application
./scripts/add-app.sh grafana
```

This script will:

1. Create the Helm chart structure in `apps/grafana/`
2. Create production values in `environments/grafana-values.yaml`
3. Create ArgoCD application manifest in `argocd/apps/grafana.yaml`
4. Provide next steps for customization

**Manual process (if you prefer):**

1. Create Helm chart: `helm create apps/new-app`
2. Create values file: `environments/new-app-values.yaml`
3. Copy and customize: `argocd/apps/_template.yaml` → `argocd/apps/new-app.yaml`
4. Commit and push - ArgoCD will automatically pick up the new app

### Updating Application Version

1. Update `appVersion` in `apps/open-webui/Chart.yaml`
2. Update `tag` in `apps/open-webui/values.yaml`
3. Test locally, then commit changes
4. ArgoCD will automatically detect and sync changes

## Troubleshooting

### Common Issues

1. **Image Pull Errors**:

   ```bash
   kubectl describe pod <pod-name> -n <namespace>
   ```

2. **Persistent Volume Issues**:

   ```bash
   kubectl get pvc -n <namespace>
   kubectl describe pvc <pvc-name> -n <namespace>
   ```

3. **Ingress Not Working**:

   ```bash
   kubectl get ingress -n <namespace>
   kubectl describe ingress <ingress-name> -n <namespace>
   ```

4. **ArgoCD Sync Issues**:
   ```bash
   argocd app get <app-name>
   argocd app sync <app-name> --prune
   ```

### Useful Commands

```bash
# Port forward for local access
kubectl port-forward service/open-webui 8080:80 -n open-webui

# Check application health
kubectl get all -n open-webui

# View application logs
kubectl logs -f deployment/open-webui -n open-webui

# Delete and redeploy
argocd app delete open-webui
kubectl apply -f argocd/apps/open-webui.yaml
```

## Security Considerations

1. **Use secrets** for sensitive environment variables
2. **Enable RBAC** and proper service accounts
3. **Configure network policies** if required
4. **Use TLS** for production ingress
5. **Regular security updates** of container images
6. **Backup persistent data** regularly

## Maintenance

1. **Regular Updates**: Monitor Open WebUI releases and update versions
2. **Backup Strategy**: Ensure persistent volumes are backed up
3. **Monitoring**: Set up monitoring and alerting for the application
4. **Log Management**: Configure log aggregation and retention
