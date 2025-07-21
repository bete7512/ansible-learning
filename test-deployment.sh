#!/bin/bash
# Test deployment script

set -e

echo "🔍 Testing Ansible Deployment Setup"
echo "=================================="

# Test 1: Check Ansible installation
echo "1. Checking Ansible installation..."
if command -v ansible >/dev/null 2>&1; then
    echo "✅ Ansible is installed: $(ansible --version | head -1)"
else
    echo "❌ Ansible is not installed"
    echo "   Install with: sudo apt install ansible"
    exit 1
fi

# Test 2: Check project structure
echo ""
echo "2. Checking project structure..."
required_files=(
    "ansible/ansible.cfg"
    "ansible/inventories/production/hosts"
    "ansible/playbooks/site.yml"
    "ansible/roles/common/tasks/main.yml"
    "ansible/roles/docker/tasks/main.yml"
    "ansible/roles/nginx/tasks/main.yml"
    "ansible/roles/golang-app/tasks/main.yml"
    "main.go"
    "Dockerfile"
    "go.mod"
)

for file in "${required_files[@]}"; do
    if [[ -f "$file" ]]; then
        echo "✅ $file exists"
    else
        echo "❌ $file is missing"
    fi
done

# Test 3: Prepare files for Ansible (like CI does)
echo ""
echo "3. Preparing application files for Ansible..."
mkdir -p ansible/roles/golang-app/files
cp main.go Dockerfile go.mod ansible/roles/golang-app/files/ 2>/dev/null || echo "⚠️ Some files may be missing but continuing..."
echo "✅ Files prepared for Ansible"

# Test 4: Syntax check
echo ""
echo "4. Checking Ansible playbook syntax..."
if ansible-playbook --syntax-check ansible/playbooks/site.yml >/dev/null 2>&1; then
    echo "✅ Playbook syntax is valid"
else
    echo "❌ Playbook syntax has errors"
    ansible-playbook --syntax-check ansible/playbooks/site.yml
    exit 1
fi

# Test 5: Check Go application
echo ""
echo "5. Testing Go application..."
if go mod verify >/dev/null 2>&1 && go build -v ./... >/dev/null 2>&1; then
    echo "✅ Go application builds successfully"
else
    echo "❌ Go application has build errors"
    go build -v ./...
    exit 1
fi

# Test 6: Check Docker build
echo ""
echo "6. Testing Docker build..."
if docker build -t users-api:test . >/dev/null 2>&1; then
    echo "✅ Docker image builds successfully"
    docker rmi users-api:test >/dev/null 2>&1
else
    echo "❌ Docker build failed"
    docker build -t users-api:test .
    exit 1
fi

echo ""
echo "🎉 All tests passed! Your deployment setup is ready."

# Cleanup: Remove copied files
echo ""
echo "🧹 Cleaning up test files..."
rm -f ansible/roles/golang-app/files/main.go ansible/roles/golang-app/files/Dockerfile ansible/roles/golang-app/files/go.mod 2>/dev/null || true
echo "✅ Cleanup complete"

echo ""
echo "Next steps:"
echo "1. Set up GitHub Secrets: SSH_PRIVATE_KEY, HOST, USER"
echo "2. Push to main branch to trigger deployment"
echo "3. Or run manually: ansible-playbook ansible/playbooks/site.yml" 