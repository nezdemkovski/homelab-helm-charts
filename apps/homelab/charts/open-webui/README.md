# Open WebUI Helm Chart

This Helm chart deploys [Open WebUI](https://github.com/open-webui/open-webui), a user-friendly WebUI for Large Language Models (LLMs) like ChatGPT, supporting various LLM runners including Ollama and OpenAI-compatible APIs.

**Current Version**: v0.6.22 (Latest as of August 2025)

## Prerequisites

- Kubernetes 1.19+
- Helm 3.2.0+
- PV provisioner support in the underlying infrastructure (if persistence is enabled)

## Installing the Chart

To install the chart with the release name `open-webui`:

```bash
helm install open-webui .
```

To install with custom values:

```bash
helm install open-webui . -f values-example.yaml
```

## Uninstalling the Chart

To uninstall/delete the `open-webui` deployment:

```bash
helm delete open-webui
```

## Configuration

The following table lists the configurable parameters of the Open WebUI chart and their default values.

### Basic Configuration

| Parameter          | Description                      | Default                         |
| ------------------ | -------------------------------- | ------------------------------- |
| `replicaCount`     | Number of replicas               | `1`                             |
| `image.repository` | Image repository                 | `ghcr.io/open-webui/open-webui` |
| `image.tag`        | Image tag (overrides appVersion) | `""`                            |
| `image.pullPolicy` | Image pull policy                | `IfNotPresent`                  |

### Service Configuration

| Parameter            | Description    | Default     |
| -------------------- | -------------- | ----------- |
| `service.type`       | Service type   | `ClusterIP` |
| `service.port`       | Service port   | `80`        |
| `service.targetPort` | Container port | `8080`      |

### Ingress Configuration

| Parameter             | Description               | Default                                                                               |
| --------------------- | ------------------------- | ------------------------------------------------------------------------------------- |
| `ingress.enabled`     | Enable ingress            | `false`                                                                               |
| `ingress.className`   | Ingress class name        | `""`                                                                                  |
| `ingress.annotations` | Ingress annotations       | `{}`                                                                                  |
| `ingress.hosts`       | Ingress hosts             | `[{host: chart-example.local, paths: [{path: /, pathType: ImplementationSpecific}]}]` |
| `ingress.tls`         | Ingress TLS configuration | `[]`                                                                                  |

### Persistence Configuration

| Parameter                  | Description        | Default           |
| -------------------------- | ------------------ | ----------------- |
| `persistence.enabled`      | Enable persistence | `true`            |
| `persistence.storageClass` | Storage class      | `""`              |
| `persistence.accessModes`  | Access modes       | `[ReadWriteOnce]` |
| `persistence.size`         | Storage size       | `2Gi`             |

### Environment Variables

| Parameter | Description           | Default |
| --------- | --------------------- | ------- |
| `env`     | Environment variables | `[]`    |

Common environment variables for Open WebUI:

- `OLLAMA_BASE_URL`: URL to Ollama instance (e.g., `http://ollama:11434`)
- `OPENAI_API_KEY`: OpenAI API key for GPT models
- `WEBUI_AUTH`: Enable authentication (`true`/`false`)
- `ENABLE_SIGNUP`: Allow new user registration (`true`/`false`)
- `DEFAULT_USER_ROLE`: Default role for new users (`pending`/`user`/`admin`)

## New Features in v0.6.22

The latest version includes several enhancements:

- **🔗 OpenAI API '/v1' Endpoint Compatibility**: Enhanced API compatibility supporting requests to paths like '/v1/models', '/v1/embeddings', and '/v1/chat/completions'
- **🪄 Toggle for Guided Response Regeneration Menu**: New setting in Interface settings for controlling the expanded guided response regeneration menu
- **✨ General UI/UX Enhancements**: Improved visual consistency with more rounded corners and layout adjustments
- **🌐 Localization Improvements**: Added support for Kabyle (Taqbaylit) language and expanded Chinese translations
- **🐞 Bug Fixes**: Improved error message propagation, fixed Pinecone and S3 vector issues, and resolved landing page settings

For complete release notes, see: [Open WebUI Releases](https://github.com/open-webui/open-webui/releases)

## Examples

### Basic Installation with Ollama

```yaml
# values.yaml
env:
  - name: OLLAMA_BASE_URL
    value: "http://ollama:11434"

persistence:
  enabled: true
  size: 5Gi

resources:
  limits:
    cpu: 500m
    memory: 512Mi
  requests:
    cpu: 100m
    memory: 256Mi
```

### Installation with Ingress

```yaml
# values.yaml
ingress:
  enabled: true
  className: "nginx"
  annotations:
    cert-manager.io/cluster-issuer: "letsencrypt-prod"
  hosts:
    - host: open-webui.example.com
      paths:
        - path: /
          pathType: ImplementationSpecific
  tls:
    - secretName: open-webui-tls
      hosts:
        - open-webui.example.com

env:
  - name: OLLAMA_BASE_URL
    value: "http://ollama:11434"
```

## Upgrading

To upgrade the chart:

```bash
helm upgrade open-webui . -f your-values.yaml
```

## Troubleshooting

### Common Issues

1. **Pod fails to start**: Check if the persistent volume is properly mounted and accessible.
2. **Cannot connect to Ollama**: Ensure the `OLLAMA_BASE_URL` environment variable points to the correct Ollama service.
3. **Ingress not working**: Verify your ingress controller is properly configured and the DNS points to your cluster.

### Checking Logs

```bash
kubectl logs -f deployment/open-webui
```

### Accessing the Application

If using port-forward for testing:

```bash
kubectl port-forward service/open-webui 8080:80
```

Then access http://localhost:8080 in your browser.
