#!/bin/bash

# Script to update sealed-secrets.yaml with encrypted values from plain-secrets.txt
# Usage: ./update-sealed-secrets.sh

set -e

PLAIN_SECRETS_FILE="plain-secrets.txt"
SEALED_SECRETS_FILE="apps/homelab/templates/sealed-secrets.yaml"
PUBLIC_KEY_FILE="sealed-secrets-public.pem"

# Check if required files exist
if [[ ! -f "$PLAIN_SECRETS_FILE" ]]; then
    echo "Error: $PLAIN_SECRETS_FILE not found!"
    exit 1
fi

if [[ ! -f "$PUBLIC_KEY_FILE" ]]; then
    echo "Error: $PUBLIC_KEY_FILE not found!"
    exit 1
fi

if [[ ! -f "$SEALED_SECRETS_FILE" ]]; then
    echo "Error: $SEALED_SECRETS_FILE not found!"
    exit 1
fi

echo "🔐 Encrypting secrets from $PLAIN_SECRETS_FILE..."

# Create a temporary file to store the new sealed secrets content
TEMP_FILE=$(mktemp)

# Copy the file up to the encryptedData section
sed '/encryptedData:/q' "$SEALED_SECRETS_FILE" > "$TEMP_FILE"

# Process each line in plain-secrets.txt
while IFS=': ' read -r key value; do
    if [[ -n "$key" && -n "$value" ]]; then
        echo "  Encrypting $key..."
        
        # Encrypt the secret using kubeseal with proper namespace scope
        encrypted_value=$(echo -n "$value" | kubectl create secret generic homelab-apps-secrets \
            --dry-run=client --from-file="$key"=/dev/stdin --namespace=homelab-apps -o yaml | \
            kubeseal --controller-name=sealed-secrets --controller-namespace=kube-system \
            --cert "$PUBLIC_KEY_FILE" --format yaml | \
            grep "$key:" | awk '{print $2}')
        
        # Add the encrypted value to the temp file
        echo "    $key: $encrypted_value" >> "$TEMP_FILE"
    fi
done < "$PLAIN_SECRETS_FILE"

# Add the rest of the template section
sed -n '/template:/,$p' "$SEALED_SECRETS_FILE" >> "$TEMP_FILE"

# Replace the original file
mv "$TEMP_FILE" "$SEALED_SECRETS_FILE"

echo "✅ Successfully updated $SEALED_SECRETS_FILE with encrypted secrets!"
echo "📝 All secrets from $PLAIN_SECRETS_FILE have been encrypted and applied."
