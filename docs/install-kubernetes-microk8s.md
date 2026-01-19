# Requirements

- **MicroK8s** - [Installation guide](https://microk8s.io/docs/install-alternatives)

# Install Kubernetes (MicroK8S)

1. **Set up Kubernetes configuration**
  ```bash
  # Generate kube config
  microk8s config > ~/.kube/config

  # Check kubernetes pods
  kubectl get pods -A
  ```
