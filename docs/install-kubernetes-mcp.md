# Requirements

- Finish [Install Kubernetes (MicroK8S)](./install-kubernetes-microk8s.md) first

# Install Kubernetes MCP

Using [Azure/mcp-kubernetes](https://github.com/Azure/mcp-kubernetes) - operates kubectl/helm directly.

1. Clone the repository:

```bash
git clone https://github.com/do-exploit/exia
cd exia/kubernetes-mcp-server/
```

2. Open [deployment.yaml](../kubernetes-mcp-server/deployment.yaml) and edit it

3. Change `/home/ubuntu` to your home directory. Run `echo $HOME` to find your home directory

4. Start the services:

```bash
kubectl apply -f deployment.yaml

# Check kubernetes MCP pods status
kubectl get pods
```

5. Expose the services with HTTPS. [Learn how to do this here](https://www.google.com/search?q=how+to+expose+kubernetes+service+to+https). The kubernetes MCP must be exposed with HTTPS, or the LLM will not use the MCP.

## Kubernetes MCP Alternatives

Alternatives tried but didn't work:
- [containers/kubernetes-mcp-server#359](https://github.com/containers/kubernetes-mcp-server/issues/359)
- [Flux159/mcp-server-kubernetes#190](https://github.com/Flux159/mcp-server-kubernetes/issues/190)
