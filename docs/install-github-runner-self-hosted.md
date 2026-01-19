# Requirements

- Finish [Create a GitHub API Key for Self-hosted GitHub Actions](./create-github-api-key-for-self-hosted-github-actions.md)
- Finish [Create GitHub Organization](./create-github-organization.md)
- Finish [Fork do-exploit/exia-examples to Your Organization](./fork-exia-examples-to-your-organization.md)

# Install GitHub Runner (Self-hosted)

1. Install the Actions Runner Controller (ARC):

```bash
helm upgrade arc \
    --install \
    --namespace arc-runners \
    --create-namespace \
    oci://ghcr.io/actions/actions-runner-controller-charts/gha-runner-scale-set-controller:0.13.0
```

2. Install the Runner Scale Set Workers:

- Replace `REPLACE_WITH_YOUR_GITHUB_TOKEN` with your GitHub Token that you saved earlier
- Replace `REPLACE_WITH_YOUR_GITHUB_ORG` with your GitHub Organization

```bash
helm upgrade "arc-exia-examples" \
    --namespace "arc-runners-workers" \
    --install \
    --create-namespace \
    --set githubConfigSecret.github_token=REPLACE_WITH_YOUR_GITHUB_TOKEN \
    --set githubConfigUrl=https://github.com/REPLACE_WITH_YOUR_GITHUB_ORG/exia-examples \
    -f values.workers.yaml \
    oci://ghcr.io/actions/actions-runner-controller-charts/gha-runner-scale-set:0.13.0
```

3. Grant permissions:

```bash
kubectl apply -f clusterroleadmin.yaml
kubectl create clusterrolebinding arc-exia-examples-deployer \
  --clusterrole=cluster-admin \
  --serviceaccount=arc-runners-workers:arc-exia-examples-gha-rs-no-permission
```

Now, your runner are ready to use.

```yaml
jobs:
  job_name:
    # Runner scale set release name
    runs-on: arc-exia-examples
```
