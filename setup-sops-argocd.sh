#!/bin/bash
# One-time setup to enable SOPS in ArgoCD
# After this, just git push and everything works!

echo "🔧 Setting up SOPS support in ArgoCD..."

# 1. Enable Kustomize plugins in ArgoCD
kubectl patch configmap argocd-cm -n argocd --patch '
data:
  kustomize.buildOptions: "--enable-alpha-plugins --enable-exec"
'

# 2. Patch repo-server to install KSOPS
kubectl patch deployment argocd-repo-server -n argocd --patch '
spec:
  template:
    spec:
      initContainers:
      - name: install-ksops
        image: viaductoss/ksops:v4.3.2
        command: ["/bin/sh", "-c"]
        args:
          - |
            echo "Installing KSOPS and SOPS..."
            cp ksops /custom-tools/
            cp kustomize /custom-tools/
            # Install SOPS
            wget -O /custom-tools/sops https://github.com/mozilla/sops/releases/download/v3.8.1/sops-v3.8.1.linux.amd64
            chmod +x /custom-tools/sops
            echo "Done installing tools."
        volumeMounts:
        - mountPath: /custom-tools
          name: custom-tools
      containers:
      - name: repo-server
        env:
        - name: PATH
          value: /custom-tools:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
        - name: SOPS_AGE_KEY_FILE
          value: /sops/key.txt
        - name: XDG_CONFIG_HOME
          value: /tmp
        volumeMounts:
        - mountPath: /custom-tools
          name: custom-tools
        - mountPath: /sops
          name: sops-age-key
          readOnly: true
      volumes:
      - name: custom-tools
        emptyDir: {}
      - name: sops-age-key
        secret:
          secretName: sops-age-key
          defaultMode: 0400
'

echo "✅ SOPS support installed in ArgoCD!"
