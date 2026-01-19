# Exia

An AI agent experiment for diagnosing CI/CD failures.

These scripts work with https://github.com/do-exploit/exia-examples.

> [!CAUTION]
> This is not a production-ready setup. It focuses on functionality and exploration only. For real use, you should think about security and proper infrastructure setup.

## Simple Test

Since we already have a dataset at https://github.com/do-exploit/exia-examples/actions, the simple test is designed to investigate existing data instead of using your own GitHub repository or Kubernetes cluster.

1. [Create a Gemini API Key for n8n](./docs/create-gemini-api-key-for-n8n.md)
2. [Create a GitHub API Key for n8n](./docs/create-github-api-key-for-n8n.md)
3. [Install n8n](./docs/install-n8n.md)
4. [Create a Simple n8n Workflow](./docs/create-simple-n8n-workflow.md)
5. [Run the Test](./docs/testing-simple.md)

## Advanced Test

If you prefer the agent to investigate from your own GitHub repository and Kubernetes cluster, you can follow these steps:

1. [Create a Gemini API Key for n8n](./docs/create-gemini-api-key-for-n8n.md)
2. [Create GitHub Organization](./docs/create-github-organization.md)
3. [Fork do-exploit/exia-examples to Your Organization](./docs/fork-exia-examples-to-your-organization.md)
4. [Create a GitHub API Key for Self-hosted GitHub Actions](./docs/create-github-api-key-for-self-hosted-github-actions.md)
5. [Create a GitHub API Key for n8n](./docs/create-github-api-key-for-n8n.md)
6. [Install Kubernetes (Microk8s)](./docs/install-kubernetes-microk8s.md)
7. [Install Kubernetes MCP](./docs/install-kubernetes-mcp.md)
8. [Install GitHub Runner (Self-hosted)](./docs/install-github-runner-self-hosted.md)
9. [Install n8n](./docs/install-n8n.md)
10. [Create an Advanced n8n Workflow](./docs/create-advanced-n8n-workflow.md)
11. [Run the Test](./docs/testing-advanced.md)

> [!IMPORTANT]
>
> - This script is only supported on Linux systems (bash).
