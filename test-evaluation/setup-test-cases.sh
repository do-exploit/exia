#!/bin/bash
# Script to create synthetic dataset for CI/CD failure scenarios
# This will create 35 training cases and 15 test cases

set -e

# Color codes for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}Creating Synthetic CI/CD Failure Dataset${NC}"
echo -e "${GREEN}========================================${NC}"

# Get current branch to return to later
ORIGINAL_BRANCH=$(git rev-parse --abbrev-ref HEAD)

# Function to create a branch with specific failure
create_failure_branch() {
    local branch_name=$1
    local failure_type=$2
    local description=$3

    echo -e "\n${YELLOW}Creating branch: ${branch_name}${NC}"
    echo -e "Failure Type: ${failure_type}"
    echo -e "Description: ${description}"

    # Create and checkout new branch (force if exists)
    git checkout main
    git branch -D "${branch_name}" 2>/dev/null || true
    git checkout -b "${branch_name}"

    # Apply failure based on type
    case $failure_type in
        "missing-dependency")
            # Remove a dependency from pyproject.toml
            sed -i 's/fastapi = "^0.115.0"/# fastapi = "^0.115.0"/' applications/fastapi-starter-python/pyproject.toml
            cd applications/fastapi-starter-python && poetry lock && cd ../..
            git add applications/fastapi-starter-python/pyproject.toml applications/fastapi-starter-python/poetry.lock
            ;;

        "syntax-error-python")
            # Introduce syntax error in app.py
            sed -i '1i import invalid syntax here' applications/fastapi-starter-python/fastapi_starter_python/app.py
            git add applications/fastapi-starter-python/fastapi_starter_python/app.py
            ;;

        "wrong-python-version")
            # Change Python version requirement
            sed -i 's/python = ">=3.11,<3.13"/python = ">=3.15,<3.17"/' applications/fastapi-starter-python/pyproject.toml
            cd applications/fastapi-starter-python && poetry lock --no-update 2>/dev/null || true && cd ../..
            git add applications/fastapi-starter-python/pyproject.toml applications/fastapi-starter-python/poetry.lock
            ;;

        "missing-import")
            # Add import for non-existent module
            sed -i '1i from nonexistent_module import something' applications/fastapi-starter-python/fastapi_starter_python/app.py
            git add applications/fastapi-starter-python/fastapi_starter_python/app.py
            ;;

        "dockerfile-syntax")
            # Break Dockerfile syntax
            sed -i 's/FROM python:3.12-slim AS runtime/FORM python:3.12-slim AS runtime/' applications/fastapi-starter-python/Dockerfile
            git add applications/fastapi-starter-python/Dockerfile
            ;;

        "memory-limit-low")
            # Set unrealistic memory limits
            sed -i 's/memory: "256Mi"/memory: "1Mi"/' deployment/kubernetes/dev/fastapi-starter-python/app.yaml
            sed -i 's/memory: "512Mi"/memory: "2Mi"/' deployment/kubernetes/dev/fastapi-starter-python/app.yaml
            git add deployment/kubernetes/dev/fastapi-starter-python/app.yaml
            ;;

        "cpu-limit-low")
            # Set unrealistic CPU limits
            sed -i 's/cpu: "250m"/cpu: "1m"/' deployment/kubernetes/dev/fastapi-starter-python/app.yaml
            sed -i 's/cpu: "500m"/cpu: "2m"/' deployment/kubernetes/dev/fastapi-starter-python/app.yaml
            git add deployment/kubernetes/dev/fastapi-starter-python/app.yaml
            ;;

        "wrong-port")
            # Change port configuration incorrectly
            sed -i 's/containerPort: 8000/containerPort: 9999/' deployment/kubernetes/dev/fastapi-starter-python/app.yaml
            git add deployment/kubernetes/dev/fastapi-starter-python/app.yaml
            ;;

        "invalid-yaml")
            # Break YAML syntax
            sed -i '10i invalid: yaml: syntax: here:' deployment/kubernetes/dev/fastapi-starter-python/app.yaml
            git add deployment/kubernetes/dev/fastapi-starter-python/app.yaml
            ;;

        "wrong-image-tag")
            # Use non-existent image tag in deployment workflow
            sed -i 's/\${{ inputs.commit_id }}/nonexistent-tag-12345/' .github/workflows/deployment-kubernetes.yaml
            git add .github/workflows/deployment-kubernetes.yaml
            ;;

        "missing-health-endpoint")
            # Remove health check endpoint
            sed -i '/@router.get("\/health"/,/return HealthcheckResponse/d' applications/fastapi-starter-python/fastapi_starter_python/api/router/healthcheck.py
            cd applications/fastapi-starter-python
            poetry run pre-commit run --all-files || :
            cd ../../
            git add applications/fastapi-starter-python/fastapi_starter_python/api/router/healthcheck.py
            ;;

        "incorrect-env-var")
            # Add incorrect environment variable
            sed -i '/UVICORN_WORKERS/a\            - name: INVALID_CONFIG\n              value: "broken_value"' deployment/kubernetes/dev/fastapi-starter-python/app.yaml
            git add deployment/kubernetes/dev/fastapi-starter-python/app.yaml
            ;;

        "test-failure")
            # Make test fail
            sed -i 's/assert response.status_code == 200/assert response.status_code == 500/' applications/fastapi-starter-python/tests/unit/test_app.py
            git add applications/fastapi-starter-python/tests/unit/test_app.py
            ;;

        "linter-error")
            # Introduce linting issues
            echo -e "\n\n\n\n\n\n\n\n" >> applications/fastapi-starter-python/fastapi_starter_python/app.py
            echo "unused_variable = 'this will cause linter error'" >> applications/fastapi-starter-python/fastapi_starter_python/app.py
            git add applications/fastapi-starter-python/fastapi_starter_python/app.py
            ;;

        "missing-dockerfile")
            # Remove Dockerfile
            git rm applications/fastapi-starter-python/Dockerfile
            ;;

        "wrong-base-image")
            # Use wrong base image
            sed -i 's/python:3.12-slim/python:2.7-slim/' applications/fastapi-starter-python/Dockerfile
            git add applications/fastapi-starter-python/Dockerfile
            ;;

        "replicas-too-high")
            # Set unrealistic replica count
            sed -i 's/replicas: 2/replicas: 10000/' deployment/kubernetes/dev/fastapi-starter-python/app.yaml
            git add deployment/kubernetes/dev/fastapi-starter-python/app.yaml
            ;;

        "service-port-mismatch")
            # Service port doesn't match container port
            sed -i 's/targetPort: 8000/targetPort: 8080/' deployment/kubernetes/dev/fastapi-starter-python/app.yaml
            git add deployment/kubernetes/dev/fastapi-starter-python/app.yaml
            ;;

        "wrong-selector")
            # Mismatch between selector and labels
            sed -i 's/app: fastapi-starter-python/app: wrong-app-name/' deployment/kubernetes/dev/fastapi-starter-python/app.yaml
            git add deployment/kubernetes/dev/fastapi-starter-python/app.yaml
            ;;

        "missing-probe-path")
            # Use wrong health check path
            sed -i 's|path: /health|path: /nonexistent|g' deployment/kubernetes/dev/fastapi-starter-python/app.yaml
            git add deployment/kubernetes/dev/fastapi-starter-python/app.yaml
            ;;

        "circular-dependency")
            # Create circular import
            echo "from fastapi_starter_python.app import app" >> applications/fastapi-starter-python/fastapi_starter_python/api/router/__init__.py
            git add applications/fastapi-starter-python/fastapi_starter_python/api/router/__init__.py
            ;;

        "poetry-lock-mismatch")
            # Modify pyproject.toml without updating lock file (intentionally skip poetry lock)
            sed -i 's/fastapi = "^0.115.0"/fastapi = "^0.100.0"/' applications/fastapi-starter-python/pyproject.toml
            git add applications/fastapi-starter-python/pyproject.toml
            ;;

        "incompatible-versions")
            # Add incompatible dependency versions
            sed -i '/pydantic = "^2.0.0"/a pydantic-core = "^1.0.0"' applications/fastapi-starter-python/pyproject.toml
            cd applications/fastapi-starter-python && poetry lock 2>/dev/null || true && cd ../..
            git add applications/fastapi-starter-python/pyproject.toml applications/fastapi-starter-python/poetry.lock
            ;;

        "missing-entrypoint")
            # Remove entrypoint script
            git rm applications/fastapi-starter-python/entrypoint.sh
            ;;

        "shell-syntax-error")
            # Introduce shell syntax error in build script
            sed -i '1i #!/bin/bash\nif [ $? -eq 0 ' applications/fastapi-starter-python/build.ci.sh
            git add applications/fastapi-starter-python/build.ci.sh
            ;;

        "python-version-mismatch")
            # Use Python 3.11 base while code requires 3.12+
            sed -i 's/michaelact\/poetry:2.1.4-py3.12/michaelact\/poetry:2.1.4-py3.11/' applications/fastapi-starter-python/Dockerfile
            git add applications/fastapi-starter-python/Dockerfile
            ;;

        "wrong-workdir")
            # Set wrong working directory
            sed -i 's|WORKDIR /app|WORKDIR /wrong/path|' applications/fastapi-starter-python/Dockerfile
            git add applications/fastapi-starter-python/Dockerfile
            ;;

        "broken-copy-command")
            # Break COPY command in Dockerfile
            sed -i 's|COPY . /app|COPY ./nonexistent /app|' applications/fastapi-starter-python/Dockerfile
            git add applications/fastapi-starter-python/Dockerfile
            ;;

        "startup-crash")
            # Make app crash on startup
            sed -i '1i import sys; sys.exit(1)' applications/fastapi-starter-python/fastapi_starter_python/app.py
            git add applications/fastapi-starter-python/fastapi_starter_python/app.py
            ;;

        "negative-initial-delay")
            # Set negative initialDelaySeconds which is invalid
            sed -i 's/initialDelaySeconds: 10/initialDelaySeconds: -5/' deployment/kubernetes/dev/fastapi-starter-python/app.yaml
            sed -i 's/initialDelaySeconds: 5/initialDelaySeconds: -3/' deployment/kubernetes/dev/fastapi-starter-python/app.yaml
            git add deployment/kubernetes/dev/fastapi-starter-python/app.yaml
            ;;

        "imagepull-policy-error")
            # Set impossible image pull policy
            sed -i 's/imagePullPolicy: Always/imagePullPolicy: InvalidPolicy/' deployment/kubernetes/dev/fastapi-starter-python/app.yaml
            git add deployment/kubernetes/dev/fastapi-starter-python/app.yaml
            ;;

        "probe-port-name-typo")
            # Typo in probe port name reference
            sed -i 's/port: http/port: htttp/' deployment/kubernetes/dev/fastapi-starter-python/app.yaml
            git add deployment/kubernetes/dev/fastapi-starter-python/app.yaml
            ;;

        "resource-quota-exceeded")
            # Set resources that would exceed typical quotas
            sed -i 's/memory: "256Mi"/memory: "256Gi"/' deployment/kubernetes/dev/fastapi-starter-python/app.yaml
            sed -i 's/memory: "512Mi"/memory: "512Gi"/' deployment/kubernetes/dev/fastapi-starter-python/app.yaml
            sed -i 's/cpu: "250m"/cpu: "250000m"/' deployment/kubernetes/dev/fastapi-starter-python/app.yaml
            git add deployment/kubernetes/dev/fastapi-starter-python/app.yaml
            ;;

        "invalid-api-version")
            # Use wrong API version
            sed -i 's/apiVersion: v1/apiVersion: v99/' deployment/kubernetes/dev/fastapi-starter-python/app.yaml
            git add deployment/kubernetes/dev/fastapi-starter-python/app.yaml
            ;;

        "missing-namespace")
            # Break namespace syntax in deployment workflow
            sed -i "s/namespace: '\${{ env.PROJECT }}-\${{ inputs.environment }}'/namespace: '\${{ env.PROJECT }}-\${{ inputs.nonexistent_var }}'/" .github/workflows/deployment-kubernetes.yaml
            git add .github/workflows/deployment-kubernetes.yaml
            ;;

        "undefined-settings-variable")
            # Reference undefined settings variable
            sed -i 's/settings.VERSION_NUMBER/settings.NONEXISTENT_VERSION/' applications/fastapi-starter-python/fastapi_starter_python/app.py
            git add applications/fastapi-starter-python/fastapi_starter_python/app.py
            ;;

        "pre-commit-hook-fail")
            # Add file that violates pre-commit rules
            echo "import os,sys,json" > applications/fastapi-starter-python/fastapi_starter_python/bad_imports.py
            git add applications/fastapi-starter-python/fastapi_starter_python/bad_imports.py
            ;;

        "type-checking-error")
            # Introduce type checking errors
            sed -i 's/message: str/message: dict/' applications/fastapi-starter-python/fastapi_starter_python/api/model/response.py
            git add applications/fastapi-starter-python/fastapi_starter_python/api/model/response.py
            ;;

        "container-security-issue")
            # Run as root (security issue)
            sed -i '/FROM python:3.12-slim AS runtime/a USER root' applications/fastapi-starter-python/Dockerfile
            git add applications/fastapi-starter-python/Dockerfile
            ;;

        "volume-mount-missing")
            # Reference non-existent volume
            sed -i '/containers:/a\      volumes:\n        - name: missing-volume\n          emptyDir: {}' deployment/kubernetes/dev/fastapi-starter-python/app.yaml
            git add deployment/kubernetes/dev/fastapi-starter-python/app.yaml
            ;;

        "rolling-update-config-error")
            # Invalid rolling update configuration
            sed -i 's/maxSurge: 1/maxSurge: -1/' deployment/kubernetes/dev/fastapi-starter-python/app.yaml
            sed -i 's/maxUnavailable: 0/maxUnavailable: 100/' deployment/kubernetes/dev/fastapi-starter-python/app.yaml
            git add deployment/kubernetes/dev/fastapi-starter-python/app.yaml
            ;;

        "affinity-rule-error")
            # Add invalid affinity rules
            sed -i '/restartPolicy: Always/a\      affinity:\n        nodeAffinity:\n          requiredDuringSchedulingIgnoredDuringExecution:\n            nodeSelectorTerms:\n              - matchExpressions:\n                  - key: nonexistent-label\n                    operator: In\n                    values:\n                      - nonexistent-value' deployment/kubernetes/dev/fastapi-starter-python/app.yaml
            git add deployment/kubernetes/dev/fastapi-starter-python/app.yaml
            ;;

        "init-container-fail")
            # Add failing init container
            sed -i '/spec:/a\      initContainers:\n        - name: failing-init\n          image: busybox\n          command: ["sh", "-c", "exit 1"]' deployment/kubernetes/dev/fastapi-starter-python/app.yaml
            git add deployment/kubernetes/dev/fastapi-starter-python/app.yaml
            ;;

        "secrets-not-found")
            # Reference non-existent secret
            sed -i '/env:/a\            - name: SECRET_VALUE\n              valueFrom:\n                secretKeyRef:\n                  name: nonexistent-secret\n                  key: password' deployment/kubernetes/dev/fastapi-starter-python/app.yaml
            git add deployment/kubernetes/dev/fastapi-starter-python/app.yaml
            ;;

        "configmap-not-found")
            # Reference non-existent configmap
            sed -i '/env:/a\            - name: CONFIG_VALUE\n              valueFrom:\n                configMapKeyRef:\n                  name: nonexistent-configmap\n                  key: config' deployment/kubernetes/dev/fastapi-starter-python/app.yaml
            git add deployment/kubernetes/dev/fastapi-starter-python/app.yaml
            ;;

        "pvc-not-found")
            # Reference non-existent PVC - add to pod template spec
            sed -i '/      containers:/i\      volumes:\n        - name: data-volume\n          persistentVolumeClaim:\n            claimName: nonexistent-pvc' deployment/kubernetes/dev/fastapi-starter-python/app.yaml
            git add deployment/kubernetes/dev/fastapi-starter-python/app.yaml
            ;;

        "duplicate-port")
            # Duplicate port definition
            sed -i '/- port: 8000/a\    - port: 8000\n      targetPort: 8001\n      protocol: TCP\n      name: http-duplicate' deployment/kubernetes/dev/fastapi-starter-python/app.yaml
            git add deployment/kubernetes/dev/fastapi-starter-python/app.yaml
            ;;

        "invalid-restart-policy")
            # Add container with invalid command
            sed -i '/containers:/a\        - name: wrong-container\n          image: busybox\n          command: ["invalid-command-xyz"]' deployment/kubernetes/dev/fastapi-starter-python/app.yaml
            git add deployment/kubernetes/dev/fastapi-starter-python/app.yaml
            ;;

        "test-import-error")
            # Break test imports
            sed -i 's/from fastapi_starter_python.app import app/from fastapi_starter_python.app import nonexistent_app/' applications/fastapi-starter-python/tests/unit/conftest.py
            git add applications/fastapi-starter-python/tests/unit/conftest.py
            ;;

        "build-arg-missing")
            # Reference undefined build arg
            sed -i '/FROM michaelact\/poetry:2.1.4-py3.12 AS install/a ARG UNDEFINED_ARG\nRUN echo $UNDEFINED_ARG' applications/fastapi-starter-python/Dockerfile
            git add applications/fastapi-starter-python/Dockerfile
            ;;

        "network-policy-block")
            # Invalid service type
            sed -i 's/type: ClusterIP/type: InvalidServiceType/' deployment/kubernetes/dev/fastapi-starter-python/app.yaml
            git add deployment/kubernetes/dev/fastapi-starter-python/app.yaml
            ;;

        *)
            echo -e "${RED}Unknown failure type: ${failure_type}${NC}"
            return 1
            ;;
    esac

    # Check if there are changes to commit
    if git diff --cached --quiet; then
        echo -e "${RED}✗ No changes to commit for ${branch_name}${NC}"
        echo -e "${RED}The sed command may not have matched anything${NC}"
        exit 1
    fi

    # Commit the change
    git commit -m "chore: update"

    echo -e "${GREEN}✓ Branch ${branch_name} created successfully${NC}"
}

# ============================================================================
# TRAINING CASES (15 cases)
# ============================================================================

# Build Failures - Missing Dependencies (3 cases)
create_failure_branch "training/case-1" "missing-dependency" "Missing FastAPI dependency in pyproject.toml"
create_failure_branch "training/case-2" "missing-import" "Import non-existent module in app.py"
create_failure_branch "training/case-3" "poetry-lock-mismatch" "pyproject.toml modified without updating poetry.lock"

# Build Failures - Syntax and Configuration (6 cases)
create_failure_branch "training/case-4" "syntax-error-python" "Python syntax error in app.py"
create_failure_branch "training/case-5" "dockerfile-syntax" "Dockerfile syntax error (FORM instead of FROM)"
create_failure_branch "training/case-6" "invalid-yaml" "Invalid YAML syntax in Kubernetes manifest"
create_failure_branch "training/case-7" "missing-dockerfile" "Dockerfile missing from repository"
create_failure_branch "training/case-8" "wrong-base-image" "Wrong base image version in Dockerfile"
create_failure_branch "training/case-9" "broken-copy-command" "COPY command references non-existent path"

# Test Failures (3 cases)
create_failure_branch "training/case-10" "test-failure" "Unit test assertion failure"
create_failure_branch "training/case-11" "linter-error" "Code style violations caught by linter"
create_failure_branch "training/case-12" "type-checking-error" "Type checking errors with mypy"

# Deployment Failures (3 cases)
create_failure_branch "training/case-13" "memory-limit-low" "Memory limit too low for application"
create_failure_branch "training/case-14" "wrong-port" "Container port mismatch"
create_failure_branch "training/case-15" "service-port-mismatch" "Service targetPort doesn't match container port"

# ============================================================================
# TEST CASES (35 cases)
# ============================================================================

# Build Failures - Missing Dependencies (5 cases)
create_failure_branch "test/case-1" "incompatible-versions" "Incompatible dependency versions specified"
create_failure_branch "test/case-2" "wrong-python-version" "Unsupported Python version requirement"
create_failure_branch "test/case-3" "missing-entrypoint" "Entrypoint script missing"
create_failure_branch "test/case-4" "wrong-workdir" "Incorrect WORKDIR in Dockerfile"
create_failure_branch "test/case-5" "circular-dependency" "Circular import dependency"

# Build Failures - Syntax and Configuration (5 cases)
create_failure_branch "test/case-6" "shell-syntax-error" "Shell script syntax error in build script"
create_failure_branch "test/case-7" "python-version-mismatch" "Python version mismatch in base image"
create_failure_branch "test/case-8" "startup-crash" "Application crashes on startup"
create_failure_branch "test/case-9" "duplicate-port" "Duplicate port definitions in service"
create_failure_branch "test/case-10" "probe-port-name-typo" "Health probe references wrong port name"

# Test Failures (5 cases)
create_failure_branch "test/case-11" "undefined-settings-variable" "Application references undefined settings attribute"
create_failure_branch "test/case-12" "pre-commit-hook-fail" "Pre-commit hooks validation failure"
create_failure_branch "test/case-13" "test-import-error" "Test file imports non-existent function"
create_failure_branch "test/case-14" "wrong-image-tag" "Non-existent Docker image tag"
create_failure_branch "test/case-15" "missing-health-endpoint" "Health check endpoint not implemented"

# Deployment - Resource Limitations (5 cases)
create_failure_branch "test/case-16" "cpu-limit-low" "CPU limit too low for application"
create_failure_branch "test/case-17" "resource-quota-exceeded" "Resource requests exceed cluster quota"
create_failure_branch "test/case-18" "negative-initial-delay" "Negative initialDelaySeconds in probe configuration"
create_failure_branch "test/case-19" "replicas-too-high" "Replica count exceeds available resources"
create_failure_branch "test/case-20" "incorrect-env-var" "Invalid environment variable configuration"

# Deployment - Configuration Errors (5 cases)
create_failure_branch "test/case-21" "missing-probe-path" "Wrong health probe path"
create_failure_branch "test/case-22" "wrong-selector" "Label selector mismatch"
create_failure_branch "test/case-23" "invalid-api-version" "Invalid Kubernetes API version"
create_failure_branch "test/case-24" "missing-namespace" "Deployment to non-existent namespace"
create_failure_branch "test/case-25" "imagepull-policy-error" "Invalid imagePullPolicy value"

# Deployment - Advanced Kubernetes Failures (10 cases)
create_failure_branch "test/case-26" "volume-mount-missing" "Volume referenced but not defined"
create_failure_branch "test/case-27" "rolling-update-config-error" "Invalid rolling update configuration"
create_failure_branch "test/case-28" "affinity-rule-error" "Node affinity rules cannot be satisfied"
create_failure_branch "test/case-29" "init-container-fail" "Init container fails to complete"
create_failure_branch "test/case-30" "secrets-not-found" "Referenced secret does not exist"
create_failure_branch "test/case-31" "configmap-not-found" "Referenced ConfigMap does not exist"
create_failure_branch "test/case-32" "pvc-not-found" "PersistentVolumeClaim not found"
create_failure_branch "test/case-33" "invalid-restart-policy" "Invalid container command causing CrashLoopBackOff"
create_failure_branch "test/case-34" "network-policy-block" "Invalid Service type specified"
create_failure_branch "test/case-35" "resource-quota-exceeded" "Namespace resource quota exceeded"

# Return to original branch
git checkout "${ORIGINAL_BRANCH}"

echo -e "\n${GREEN}========================================${NC}"
echo -e "${GREEN}Dataset Creation Complete!${NC}"
echo -e "${GREEN}========================================${NC}"
echo -e "${YELLOW}Created 15 training cases and 35 test cases${NC}"
echo -e "${YELLOW}Total: 50 synthetic CI/CD failure scenarios${NC}"
echo -e "\nBranches created:"
echo -e "  - training/case-1 to training/case-15"
echo -e "  - test/case-1 to test/case-35"
echo -e "\n${GREEN}You can now push all branches to GitHub:${NC}"
echo -e "  git push --all origin"
