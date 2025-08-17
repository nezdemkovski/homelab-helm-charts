# Cloudflare Tunnel Setup for ai.nezdemkovski.cloud

## Prerequisites

1. Domain `nezdemkovski.cloud` managed by Cloudflare
2. Cloudflare account with Zero Trust access

## Setup Steps

### 1. Create Cloudflare Tunnel

1. Go to **Cloudflare Dashboard** → **Zero Trust** → **Access** → **Tunnels**
2. Click **Create a tunnel**
3. Choose **Cloudflared**
4. Name: `k3s-homelab`
5. **Save the tunnel ID and token**

### 2. Configure DNS

In Cloudflare DNS, add:

```
Type: CNAME
Name: ai
Content: <TUNNEL_ID>.cfargotunnel.com
Proxy: Enabled (orange cloud)
```

### 3. Deploy to Kubernetes

1. **Create the namespace:**

   ```bash
   kubectl create namespace cloudflare-tunnel
   ```

2. **Create tunnel credentials secret:**

   ```bash
   # Download credentials.json from Cloudflare Dashboard
   kubectl create secret generic tunnel-credentials \
     --from-file=credentials.json=./credentials.json \
     -n cloudflare-tunnel
   ```

3. **Update the ConfigMap in cloudflare-tunnel.yaml:**

   - Replace `YOUR_TUNNEL_ID` with your actual tunnel ID

4. **Deploy the tunnel:**
   ```bash
   kubectl apply -f cloudflare-tunnel.yaml
   ```

### 4. Verify Setup

```bash
# Check tunnel status
kubectl get pods -n cloudflare-tunnel

# Check logs
kubectl logs -f deployment/cloudflared -n cloudflare-tunnel

# Test the connection
curl -H "Host: ai.nezdemkovski.cloud" http://localhost:8080
```

## How It Works

```
Internet → Cloudflare → Tunnel → Traefik → Open WebUI
```

1. **Cloudflare** receives HTTPS requests for `ai.nezdemkovski.cloud`
2. **Tunnel** forwards traffic to your k3s Traefik ingress
3. **Traefik** routes to Open WebUI service
4. **No ports opened** on your firewall/router

## Benefits

- ✅ **No port forwarding** required
- ✅ **Automatic SSL** handled by Cloudflare
- ✅ **DDoS protection** from Cloudflare
- ✅ **Global CDN** for better performance
- ✅ **Zero Trust** security features available

## Troubleshooting

### Tunnel not connecting:

```bash
kubectl describe pod -l app=cloudflared -n cloudflare-tunnel
```

### DNS not resolving:

- Verify CNAME record in Cloudflare DNS
- Ensure proxy is enabled (orange cloud)

### 502 Bad Gateway:

- Check if Open WebUI is running: `kubectl get pods -n open-webui`
- Verify ingress: `kubectl get ingress -n open-webui`
