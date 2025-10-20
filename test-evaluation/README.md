# Test Evaluation

Helper scripts to test AI Agent capabilities in finding CI/CD failure root causes.

## Prerequisites

- GitHub CLI (`gh`) - [Install here](https://cli.github.com/)
- Authenticate: `gh auth login`
- Git and Poetry installed

## Scripts

1. **setup-test-cases.sh** - Creates 50 failure scenarios (15 training + 35 test cases)
2. **trigger-workflow.sh** - Runs workflow and monitors results

---

## Quick Start

### 1. Setup Test Cases

```bash
cd /path/to/exia
./setup-test-cases.sh
git push --force --all origin
```

This creates branches: `training/case-1` to `training/case-15` and `test/case-1` to `test/case-35`

### 2. Run Workflow

```bash
cd /path/to/exia
./trigger-workflow.sh training/case-1
```

The script will:
- Trigger GitHub Actions workflow
- Monitor progress
- Show results and evaluation prompts
