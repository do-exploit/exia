# Kubernetes Controller for GitHub Actions Self-Hosted Runners

## Prerequisites

- Follow the [official guide](https://docs.github.com/en/actions/tutorials/use-actions-runner-controller) -- especially how to generate fine-grained tokens and the permissions required to attach them

## Quick Start

```bash
# Install Actions Runner Controller
helm upgrade arc \
    --install \
    --namespace arc-runners \
    --create-namespace \
    oci://ghcr.io/actions/actions-runner-controller-charts/gha-runner-scale-set-controller:0.13.0

# Install runner scale set
helm install "arc-exia-examples" \
    --namespace "arc-runners-workers" \
    --install \
    --create-namespace \
    -f values.workers.yaml \
    oci://ghcr.io/actions/actions-runner-controller-charts/gha-runner-scale-set:0.13.0

# Grant permissions
kubectl apply -f clusterroleadmin.yaml
./post-install.sh
```

Now, your runner are ready to use.

```yaml
jobs:
  job_name:
    # Runner scale set release name
    runs-on: arc-exia-examples
```
