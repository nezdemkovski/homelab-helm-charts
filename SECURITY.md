# Security Guidelines for Homelab Helm Charts

## 🔒 Security Overview

This document outlines the security practices and guidelines implemented in this homelab Helm charts repository.

## 🛡️ Security Features Implemented

### Container Security

- **Non-root execution**: All containers run as non-root users (UID 1000+ or 999 for PostgreSQL)
- **Read-only root filesystem**: Where possible (applications requiring write access documented)
- **Dropped capabilities**: ALL Linux capabilities dropped unless specifically needed
- **Security profiles**: seccomp profiles set to `RuntimeDefault`
- **Privilege escalation**: Disabled (`allowPrivilegeEscalation: false`)

### Secrets Management

- **Sealed Secrets**: Encrypted secrets stored in Git using Bitnami Sealed Secrets ✅
- **Cluster-side decryption**: Sealed Secrets controller handles decryption in-cluster
- **Environment separation**: Secrets properly namespaced and application-specific
- **No plaintext secrets**: All sensitive data encrypted at rest in Git

### Network Security

- **Network Policies**: Default deny-all with explicit allow rules
- **Ingress Security**: TLS termination handled by Cloudflare Tunnel
- **Pod-to-pod isolation**: Restricted communication between services
- **DNS-only egress**: Limited outbound connections

### Kubernetes Security

- **Pod Security Standards**: `restricted` level enforcement in namespaces
- **Service Account**: Minimal permissions, auto-mount disabled where possible
- **RBAC**: Role-based access control (planned implementation)
- **Resource limits**: CPU and memory limits set for all containers

### GitOps Security

- **Branch protection**: Git-based deployment with review requirements
- **Audit trail**: All changes tracked in Git history
- **Automated sync**: ArgoCD with self-healing capabilities
- **Rollback capability**: Git-based rollback mechanisms

## 🚨 Security Compliance

### Application-Specific Security

#### Cloudflared

- ✅ **Excellent security posture**
- ✅ Non-root execution (UID 65532)
- ✅ Read-only root filesystem
- ✅ ALL capabilities dropped
- ✅ seccomp profile enabled

#### N8N

- ✅ **Good security posture**
- ✅ Non-root execution (UID 1000)
- ⚠️ Read/write filesystem (required for operation)
- ✅ ALL capabilities dropped
- ✅ Encrypted database credentials

#### Open WebUI

- ✅ **Security hardened** (as of latest update)
- ✅ Non-root execution (UID 1000)
- ⚠️ Read/write filesystem (required for data storage)
- ✅ ALL capabilities dropped

#### Homarr

- ✅ **Security hardened** (as of latest update)
- ✅ Non-root execution (UID 1000) - _Previously ran as root_
- ⚠️ Read/write filesystem (required for configuration)
- ✅ ALL capabilities dropped

#### PostgreSQL (N8N)

- ✅ **Database security**
- ✅ Non-root execution (UID 999)
- ✅ Encrypted credentials
- ✅ Network isolation
- ⚠️ Read/write filesystem (required for database)

## 📋 Security Checklist

### Before Deployment

- [ ] Review all security contexts
- [ ] Verify secrets are encrypted
- [ ] Test network policies
- [ ] Validate resource limits
- [ ] Check for latest container images

### Regular Maintenance

- [ ] Update container images monthly
- [ ] Rotate secrets quarterly
- [ ] Review access logs
- [ ] Monitor security alerts
- [ ] Backup encrypted data

### Incident Response

- [ ] Document security incidents
- [ ] Update affected secrets
- [ ] Review and improve policies
- [ ] Test recovery procedures

## ⚙️ Configuration Guidelines

### Adding New Applications

1. **Security Context**: Always configure non-root execution
2. **Capabilities**: Drop ALL capabilities unless specifically needed
3. **Filesystem**: Use read-only root filesystem when possible
4. **Secrets**: Use encrypted secret management
5. **Network**: Define explicit network policies
6. **Resources**: Set appropriate limits and requests

### Example Security Configuration

```yaml
podSecurityContext:
  runAsNonRoot: true
  runAsUser: 1000
  runAsGroup: 1000
  fsGroup: 1000
  seccompProfile:
    type: RuntimeDefault

securityContext:
  allowPrivilegeEscalation: false
  readOnlyRootFilesystem: true # Set to false if write access needed
  runAsNonRoot: true
  runAsUser: 1000
  runAsGroup: 1000
  capabilities:
    drop:
      - ALL
```

## 🔍 Security Monitoring

### Recommended Tools

- **Falco**: Runtime security monitoring
- **OPA Gatekeeper**: Policy enforcement
- **Trivy**: Container vulnerability scanning
- **Kube-bench**: CIS Kubernetes benchmark

### Key Metrics to Monitor

- Pod security policy violations
- Network policy denies
- Failed authentication attempts
- Resource usage anomalies
- Container image vulnerabilities

## 📚 References

- [Kubernetes Security Best Practices](https://kubernetes.io/docs/concepts/security/)
- [Pod Security Standards](https://kubernetes.io/docs/concepts/security/pod-security-standards/)
- [Sealed Secrets](https://github.com/bitnami-labs/sealed-secrets)
- [Network Policies](https://kubernetes.io/docs/concepts/services-networking/network-policies/)

## 🚀 Future Security Enhancements

- [ ] Add Falco runtime security monitoring
- [ ] Configure OPA Gatekeeper policies
- [ ] Set up container vulnerability scanning
- [ ] Implement resource quotas
- [ ] Add admission controllers
- [ ] Configure audit logging
