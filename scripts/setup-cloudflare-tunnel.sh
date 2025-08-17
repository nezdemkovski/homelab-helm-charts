#!/bin/bash

# Script to set up Cloudflare Tunnel for k3s homelab
# Usage: ./scripts/setup-cloudflare-tunnel.sh <tunnel-id> <path-to-credentials.json>

set -e

TUNNEL_ID=$1
CREDENTIALS_FILE=$2

if [ -z "$TUNNEL_ID" ] || [ -z "$CREDENTIALS_FILE" ]; then
    echo "Usage: $0 <tunnel-id> <path-to-credentials.json>"
    echo ""
    echo "Example: $0 12345678-1234-1234-1234-123456789abc ./credentials.json"
    echo ""
    echo "Get these from Cloudflare Dashboard → Zero Trust → Access → Tunnels"
    exit 1
fi

if [ ! -f "$CREDENTIALS_FILE" ]; then
    echo "Error: Credentials file '$CREDENTIALS_FILE' not found"
    exit 1
fi

echo "Setting up Cloudflare Tunnel with ID: $TUNNEL_ID"

# Create namespace
echo "Creating cloudflare-tunnel namespace..."
kubectl create namespace cloudflare-tunnel --dry-run=client -o yaml | kubectl apply -f -

# Create credentials secret
echo "Creating tunnel credentials secret..."
kubectl create secret generic tunnel-credentials \
    --from-file=credentials.json="$CREDENTIALS_FILE" \
    -n cloudflare-tunnel \
    --dry-run=client -o yaml | kubectl apply -f -

# Update the tunnel ID in the config
echo "Updating tunnel configuration..."
sed "s/YOUR_TUNNEL_ID/$TUNNEL_ID/g" cloudflare-tunnel.yaml > /tmp/cloudflare-tunnel-configured.yaml

# Apply the configuration
echo "Deploying Cloudflare Tunnel..."
kubectl apply -f /tmp/cloudflare-tunnel-configured.yaml

# Clean up temp file
rm /tmp/cloudflare-tunnel-configured.yaml

echo ""
echo "✅ Cloudflare Tunnel deployed successfully!"
echo ""
echo "Next steps:"
echo "1. Add DNS record in Cloudflare:"
echo "   Type: CNAME"
echo "   Name: ai"
echo "   Content: $TUNNEL_ID.cfargotunnel.com"
echo "   Proxy: Enabled (orange cloud)"
echo ""
echo "2. Check tunnel status:"
echo "   kubectl get pods -n cloudflare-tunnel"
echo ""
echo "3. View logs:"
echo "   kubectl logs -f deployment/cloudflared -n cloudflare-tunnel"
echo ""
echo "4. Deploy your applications:"
echo "   kubectl apply -f argocd/homelab-apps.yaml"
