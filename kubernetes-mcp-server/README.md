# Kubernetes MCP Server

Using [Azure/mcp-kubernetes](https://github.com/Azure/mcp-kubernetes) - operates kubectl/helm directly.

## Prerequisites

- [Kubernetes cluster access via `kubectl`](https://kubernetes.io/docs/tasks/access-application-cluster/access-cluster/)

## Quick Start

```bash
kubectl apply -f deployment.yaml
```

Now, your MCP is ready to use.

![Kubernetes MCP n8n Configuration](.assets/kubernetes-mcp-n8n-configuration.png)

## Notes

Alternatives tried but didn't work:
- [containers/kubernetes-mcp-server#359](https://github.com/containers/kubernetes-mcp-server/issues/359)
- [Flux159/mcp-server-kubernetes#190](https://github.com/Flux159/mcp-server-kubernetes/issues/190)
