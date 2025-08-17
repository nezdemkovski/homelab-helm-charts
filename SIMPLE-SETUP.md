# Simple Cloudflare Tunnel Setup

## What You Need

1. Tunnel ID from Cloudflare Dashboard
2. credentials.json file downloaded from Cloudflare
3. Your k3s cluster running (which you have!)

## Step-by-Step Commands

### 1. Download credentials.json to this directory

```bash
# Make sure credentials.json is in your homelab-helm-charts folder
ls credentials.json  # Should show the file
```

### 2. Run the setup script

```bash
# Replace YOUR_TUNNEL_ID with the actual ID from Cloudflare
./scripts/secure-tunnel-setup.sh YOUR_TUNNEL_ID ./credentials.json
```

### 3. Deploy your applications

```bash
kubectl apply -f argocd/homelab-apps.yaml
```

### 4. Check everything is working

```bash
# Check tunnel status
kubectl get pods -n cloudflare-tunnel

# Check Open WebUI
kubectl get pods -n open-webui

# Check logs if needed
kubectl logs -f deployment/cloudflared -n cloudflare-tunnel
```

## That's it!

Your Open WebUI will be available at: https://ai.nezdemkovski.cloud

## If something goes wrong

1. **Tunnel pod not starting?**

   ```bash
   kubectl describe pod -l app=cloudflared -n cloudflare-tunnel
   ```

2. **Open WebUI not accessible?**

   ```bash
   kubectl get ingress -n open-webui
   kubectl get pods -n open-webui
   ```

3. **DNS not working?**
   - Check the CNAME record in Cloudflare DNS
   - Make sure the orange cloud is enabled (proxied)

## Security Note

After setup, delete the credentials.json file:

```bash
rm credentials.json
```
