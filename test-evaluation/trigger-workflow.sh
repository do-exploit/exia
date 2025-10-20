#!/bin/bash
# Script to trigger GitHub Actions workflow and wait for completion
# Usage: ./trigger-workflow.sh <branch_name>

set -e

# Color codes for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Check if branch name is provided
if [ -z "$1" ]; then
    echo -e "${RED}Error: Branch name is required${NC}"
    echo "Usage: $0 <branch_name>"
    exit 1
fi

BRANCH_NAME=$1
REPO="do-exploit/exia-examples"
WORKFLOW_FILE="build-push.yaml"

# Workflow inputs
MODULE="fastapi-starter-python"
DEPLOYMENT_TYPE="kubernetes"
DEPLOYMENT_ENVIRONMENT="dev"

echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}GitHub Actions Workflow Trigger${NC}"
echo -e "${GREEN}========================================${NC}"
echo -e "${BLUE}Branch:${NC} ${BRANCH_NAME}"
echo -e "${BLUE}Module:${NC} ${MODULE}"
echo -e "${BLUE}Deployment Type:${NC} ${DEPLOYMENT_TYPE}"
echo -e "${BLUE}Deployment Environment:${NC} ${DEPLOYMENT_ENVIRONMENT}"
echo -e "${GREEN}========================================${NC}\n"

# Check if gh CLI is installed
if ! command -v gh &> /dev/null; then
    echo -e "${RED}Error: GitHub CLI (gh) is not installed${NC}"
    echo "Please install it from: https://cli.github.com/"
    exit 1
fi

# Check if authenticated
if ! gh auth status &> /dev/null; then
    echo -e "${RED}Error: Not authenticated with GitHub CLI${NC}"
    echo "Please run: gh auth login"
    exit 1
fi

# Trigger the workflow
echo -e "${YELLOW}Triggering workflow...${NC}"
gh workflow run "${WORKFLOW_FILE}" \
    --repo "${REPO}" \
    --ref "${BRANCH_NAME}" \
    --field module="${MODULE}" \
    --field deployment_type="${DEPLOYMENT_TYPE}" \
    --field deployment_environment="${DEPLOYMENT_ENVIRONMENT}"

if [ $? -ne 0 ]; then
    echo -e "${RED}Failed to trigger workflow${NC}"
    exit 1
fi

echo -e "${GREEN}✓ Workflow triggered successfully${NC}\n"

# Wait a bit for the workflow to start
echo -e "${YELLOW}Waiting for workflow to start...${NC}"
sleep 5

# Get the latest workflow run
echo -e "${YELLOW}Finding workflow run...${NC}"
RUN_ID=""
ATTEMPTS=0
MAX_ATTEMPTS=12

while [ -z "$RUN_ID" ] && [ $ATTEMPTS -lt $MAX_ATTEMPTS ]; do
    RUN_ID=$(gh run list \
        --repo "${REPO}" \
        --workflow "${WORKFLOW_FILE}" \
        --branch "${BRANCH_NAME}" \
        --limit 1 \
        --json databaseId \
        --jq '.[0].databaseId' 2>/dev/null)

    if [ -z "$RUN_ID" ]; then
        ATTEMPTS=$((ATTEMPTS + 1))
        echo -e "${YELLOW}Attempt ${ATTEMPTS}/${MAX_ATTEMPTS} - Waiting for run to appear...${NC}"
        sleep 5
    fi
done

if [ -z "$RUN_ID" ]; then
    echo -e "${RED}Could not find workflow run${NC}"
    echo -e "${YELLOW}Please check manually:${NC}"
    echo "https://github.com/${REPO}/actions/workflows/${WORKFLOW_FILE}"
    exit 1
fi

echo -e "${GREEN}✓ Found workflow run ID: ${RUN_ID}${NC}"
echo -e "${BLUE}View workflow:${NC} https://github.com/${REPO}/actions/runs/${RUN_ID}\n"

# Watch the workflow run
echo -e "${YELLOW}Watching workflow progress...${NC}"
echo -e "${YELLOW}========================================${NC}\n"

gh run watch "${RUN_ID}" --repo "${REPO}" || true

echo -e "\n${YELLOW}========================================${NC}"
echo -e "${YELLOW}Fetching final workflow status...${NC}\n"

# Get final status
WORKFLOW_STATUS=$(gh run view "${RUN_ID}" \
    --repo "${REPO}" \
    --json conclusion \
    --jq '.conclusion')

# Display result
echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}Workflow Execution Complete${NC}"
echo -e "${GREEN}========================================${NC}"
echo -e "${BLUE}Run ID:${NC} ${RUN_ID}"
echo -e "${BLUE}Branch:${NC} ${BRANCH_NAME}"
echo -e "${BLUE}Status:${NC} ${WORKFLOW_STATUS}"
echo -e "${GREEN}========================================${NC}\n"

# Show detailed results
echo -e "${YELLOW}Detailed Results:${NC}\n"
gh run view "${RUN_ID}" --repo "${REPO}" --log-failed || gh run view "${RUN_ID}" --repo "${REPO}"

echo -e "\n${GREEN}========================================${NC}"
echo -e "${GREEN}Evaluation Prompt${NC}"
echo -e "${GREEN}========================================${NC}"

if [ "$WORKFLOW_STATUS" = "success" ]; then
    echo -e "${GREEN}✓ Workflow completed successfully!${NC}\n"
    echo -e "${BLUE}Please evaluate the results:${NC}"
    echo "1. Review the workflow logs above"
    echo "2. Check if all jobs completed as expected"
    echo "3. Verify the deployment in ${DEPLOYMENT_ENVIRONMENT} environment"
    echo "4. Confirm the artifact was pushed correctly"
elif [ "$WORKFLOW_STATUS" = "failure" ]; then
    echo -e "${RED}✗ Workflow failed!${NC}\n"
    echo -e "${BLUE}Please evaluate the failure:${NC}"
    echo "1. Review the error logs above"
    echo "2. Identify which job failed"
    echo "3. Analyze the root cause"
    echo "4. Document the failure type and error message"
    echo "5. Determine if this matches the expected failure for this test case"
elif [ "$WORKFLOW_STATUS" = "cancelled" ]; then
    echo -e "${YELLOW}⊘ Workflow was cancelled${NC}\n"
    echo -e "${BLUE}Please evaluate:${NC}"
    echo "1. Check why the workflow was cancelled"
    echo "2. Determine if re-running is necessary"
else
    echo -e "${YELLOW}? Workflow status: ${WORKFLOW_STATUS}${NC}\n"
    echo -e "${BLUE}Please evaluate:${NC}"
    echo "1. Review the workflow state"
    echo "2. Check for any anomalies"
fi

echo -e "\n${BLUE}View full details:${NC}"
echo "https://github.com/${REPO}/actions/runs/${RUN_ID}"
echo -e "\n${GREEN}========================================${NC}"

# Return appropriate exit code
if [ "$WORKFLOW_STATUS" = "success" ]; then
    exit 0
elif [ "$WORKFLOW_STATUS" = "failure" ]; then
    exit 1
else
    exit 2
fi
