# Next Steps for Deployment

Your homelab Helm charts repository is now ready for ArgoCD deployment with the App of Apps pattern!

## ✅ What's Already Configured

- ✅ **Repository URL**: Updated to `https://github.com/nezdemkovski/homelab-helm-charts.git`
- ✅ **Open WebUI v0.6.22**: Latest version with proper configuration
- ✅ **App of Apps Pattern**: Single master application manages all apps
- ✅ **Production-Ready**: Optimized for production deployment
- ✅ **Automation Scripts**: Easy way to add new applications

## 🚀 Ready to Deploy

### 1. Push to GitHub

```bash
# Initialize git if not already done
git init
git add .
git commit -m "Initial commit: Open WebUI v0.6.22 with ArgoCD App of Apps"

# Add your GitHub repository as origin
git remote add origin https://github.com/nezdemkovski/homelab-helm-charts.git

# Push to GitHub
git branch -M main
git push -u origin main
```

### 2. Deploy to ArgoCD

**One command deploys everything:**

```bash
# Deploy the master "App of Apps" application
kubectl apply -f argocd/homelab-apps.yaml

# Check status
argocd app get homelab-apps

# View all managed applications
argocd app list
```

### 3. Customize for Your Environment

Before deploying, you may want to customize `environments/open-webui-values.yaml`:

- ✅ **Domain**: Already configured for `ai.nezdemkovski.cloud`
- ✅ **SSL**: Let's Encrypt certificates configured
- ✅ **Storage**: Using k3s `local-path` storage class
- ✅ **Ingress**: Traefik with HTTPS redirect
- Configure `OLLAMA_BASE_URL` to point to your Ollama instance

**Important**: Make sure `ai.nezdemkovski.cloud` points to your server's IP (`192.168.1.26`) in DNS.

## 🔧 Adding More Applications

Use the provided script to easily add new applications:

```bash
# Add Grafana
./scripts/add-app.sh grafana

# Commit and push - ArgoCD will automatically pick it up!
git add .
git commit -m "Add Grafana application"
git push
```

## 📊 Monitoring Your Deployment

```bash
# Watch all applications
argocd app list

# Get detailed status
argocd app get open-webui

# Check pods in the namespace
kubectl get pods -n open-webui

# View application logs
kubectl logs -f deployment/open-webui -n open-webui

# Port forward for local access (if needed)
kubectl port-forward service/open-webui 8080:80 -n open-webui
```

## 🎯 What Happens After Deployment

1. **ArgoCD** will sync the master `homelab-apps` application
2. **Master app** will create individual applications:
   - `open-webui` (manual sync for production safety)
3. **Individual apps** will deploy Open WebUI to the `open-webui` namespace
4. **Future apps** you add will be automatically picked up and deployed

## 🔍 Troubleshooting

If something doesn't work:

1. **Check ArgoCD application status**:

   ```bash
   argocd app get homelab-apps
   argocd app get open-webui
   ```

2. **Check Kubernetes resources**:

   ```bash
   kubectl get all -n open-webui
   kubectl describe pod <pod-name> -n open-webui
   ```

3. **Check ArgoCD logs**:
   ```bash
   kubectl logs -n argocd -l app.kubernetes.io/name=argocd-application-controller
   ```

## 🎉 You're Ready!

Your homelab now has a professional GitOps setup with:

- ✅ Latest Open WebUI v0.6.22
- ✅ Scalable App of Apps pattern
- ✅ Environment separation
- ✅ Easy application management
- ✅ Complete automation

Happy homelabbing! 🏠⚡
