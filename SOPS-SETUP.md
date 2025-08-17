# SOPS Setup for Secure Secrets Management

This guide shows how to set up SOPS (Secrets OPerationS) to encrypt secrets in Git while keeping them accessible to ArgoCD.

## 🔧 Prerequisites

1. **Install SOPS**:

   ```bash
   # macOS
   brew install sops

   # Linux
   curl -LO https://github.com/mozilla/sops/releases/latest/download/sops-v3.8.1.linux.amd64
   sudo mv sops-v3.8.1.linux.amd64 /usr/local/bin/sops
   sudo chmod +x /usr/local/bin/sops
   ```

2. **Install Age** (recommended encryption method):

   ```bash
   # macOS
   brew install age

   # Linux
   curl -LO https://github.com/FiloSottile/age/releases/latest/download/age-v1.1.1-linux-amd64.tar.gz
   tar xzf age-v1.1.1-linux-amd64.tar.gz
   sudo mv age/age* /usr/local/bin/
   ```

## 🔑 Step 1: Generate Age Key

```bash
# Generate a new age key
age-keygen -o ~/.config/sops/age/keys.txt

# The public key will be displayed - copy it for .sops.yaml
```

## 📝 Step 2: Update SOPS Configuration

Edit `.sops.yaml` and replace the age key with your public key:

```yaml
creation_rules:
  - path_regex: .*-encrypted\.yaml$
    age: >-
      YOUR_PUBLIC_AGE_KEY_HERE
```

## 🔐 Step 3: Encrypt Your Token

1. **Add your real token** to `environments/cloudflared-values-encrypted.yaml`:

   ```yaml
   tunnel:
     token: "eyJhIjoiMTIzNDU2NzgtYWJjZC0xMjM0LWFiY2QtMTIzNDU2Nzg5YWJjIiwidCI6IjEyMzQ1Njc4LWFiY2QtMTIzNC1hYmNkLTEyMzQ1Njc4OWFiYyIsInMiOiJhYmNkZWZnaGlqa2xtbm9wcXJzdHV2d3h5ejEyMzQ1NiJ9"
   ```

2. **Encrypt the file**:

   ```bash
   sops -e -i environments/cloudflared-values-encrypted.yaml
   ```

3. **Verify encryption**:

   ```bash
   cat environments/cloudflared-values-encrypted.yaml
   # Should show encrypted content
   ```

4. **Test decryption**:
   ```bash
   sops -d environments/cloudflared-values-encrypted.yaml
   # Should show your original token
   ```

## 🚀 Step 4: Configure ArgoCD for SOPS

### Option A: ArgoCD with SOPS Plugin (Recommended)

1. **Install SOPS plugin in ArgoCD**:

   ```bash
   # Add to ArgoCD ConfigMap
   kubectl patch configmap argocd-cm -n argocd --patch '
   data:
     configManagementPlugins: |
       - name: sops
         generate:
           command: ["sh", "-c"]
           args: ["sops -d $ARGOCD_ENV_FILE > /tmp/decrypted.yaml && helm template $ARGOCD_APP_NAME . -f /tmp/decrypted.yaml"]
   '
   ```

2. **Create SOPS secret in ArgoCD namespace**:
   ```bash
   # Copy your age key to ArgoCD
   kubectl create secret generic sops-age-key \
     --from-file=key.txt=~/.config/sops/age/keys.txt \
     -n argocd
   ```

### Option B: External Secrets Operator (Alternative)

If you prefer External Secrets Operator, see the ESO setup guide.

## 📋 Step 5: Deploy

```bash
# Commit encrypted files to Git
git add .
git commit -m "Add encrypted cloudflared token"
git push

# Deploy via ArgoCD
kubectl apply -f argocd/homelab-apps.yaml
```

## 🔍 Verification

```bash
# Check if secret was created
kubectl get secret cloudflared-token -n cloudflare-tunnel

# Check if token is correctly decrypted
kubectl get secret cloudflared-token -n cloudflare-tunnel -o jsonpath='{.data.token}' | base64 -d
```

## 🛡️ Security Benefits

- ✅ **Secrets encrypted in Git**: Tokens never stored in plain text
- ✅ **GitOps compatible**: ArgoCD can decrypt and deploy
- ✅ **Key rotation**: Easy to rotate encryption keys
- ✅ **Audit trail**: All changes tracked in Git
- ✅ **Team access**: Share public keys, keep private keys secure

## 🔄 Key Rotation

To rotate your age key:

1. Generate new key: `age-keygen -o ~/.config/sops/age/keys-new.txt`
2. Update `.sops.yaml` with new public key
3. Re-encrypt files: `sops updatekeys environments/cloudflared-values-encrypted.yaml`
4. Update ArgoCD secret with new private key

## 📚 References

- [SOPS Documentation](https://github.com/mozilla/sops)
- [Age Encryption](https://github.com/FiloSottile/age)
- [ArgoCD SOPS Plugin](https://github.com/argoproj-labs/argocd-vault-plugin)
