# Requirements

- Finish [Install n8n](./install-n8n.md)
- Finish [Create GitHub API Key for n8n](./create-github-api-key-for-n8n.md)
- Finish [Create Gemini API Key for n8n](./create-gemini-api-key-for-n8n.md)
- Finish [Install Kubernetes MCP](./install-kubernetes-mcp.md)

# Create an Advanced n8n Workflow

1. Click the three-dot menu button on the top-left corner

2. Click "**Import from file**"

![n8n-import-from-file](../.assets/n8n-import-from-file.png)

3. Upload the [exia-devops-assistant.json](../n8n-workflows/exia-devops-assistant.json) workflow file

4. Double-click "Google Gemini Chat Model"

5. Click "**+ Create new credential**"

![n8n-configure-google-gemini-chat-model-step-1](../.assets/n8n-configure-google-gemini-chat-model-step-1.png)

6. Fill in your saved Gemini "**API Key**"

![n8n-configure-google-gemini-chat-model-step-2](../.assets/n8n-configure-google-gemini-chat-model-step-2.png)

7. Click "**Save**" and back to canvas

8. Double-click "**GitHub Action MCP**"

9. Click "**+ Create new credential**"

![n8n-configure-github-mcp-step-1](../.assets/n8n-configure-github-mcp-step-1.png)

10. Fill in your saved GitHub "**Bearer Token**"

![n8n-configure-github-mcp-step-2](../.assets/n8n-configure-github-mcp-step-2.png)

11. Click "**Save**" and back to canvas

![n8n-configure-google-gemini-chat-model-step-2](../.assets/n8n-exia-devops-assistant-workflow.png)

12. Double-click "**Kubernetes MCP**"

13. Set up the endpoint and authentication if needed

![n8n-configure-kubernetes-mcp-step-1](../.assets/n8n-configure-kubernetes-mcp-step-1.png)

12. Continue to [Advanced Test](./testing-advanced.md)
