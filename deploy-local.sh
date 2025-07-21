#!/bin/bash
# Local deployment script for Ansible

set -e

echo "🚀 Local Ansible Deployment"
echo "============================"

# Step 1: Prepare application files for Ansible (like CI does)
echo "📁 Preparing application files..."
mkdir -p ansible/roles/golang-app/files
cp main.go Dockerfile go.mod ansible/roles/golang-app/files/
echo "✅ Files prepared"

# Step 2: Test SSH connection
echo ""
echo "🔌 Testing SSH connection..."
if ansible webservers -m ping >/dev/null 2>&1; then
    echo "✅ SSH connection successful"
else
    echo "❌ SSH connection failed"
    echo "Make sure your server details are correct in ansible/inventories/production/hosts"
    exit 1
fi

# Step 3: Run infrastructure setup (optional, can skip if already done)
echo ""
read -p "🏗️  Run infrastructure setup? (y/N): " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo "🏗️  Setting up infrastructure..."
    ansible-playbook ansible/playbooks/setup-infrastructure.yml -v
    echo "✅ Infrastructure setup complete"
fi

# Step 4: Deploy application
echo ""
echo "🚢 Deploying application..."
ansible-playbook ansible/playbooks/deploy-app.yml -v

# Step 5: Test deployment
echo ""
echo "🧪 Testing deployment..."
HOST_IP=$(grep "userapi ansible_host" ansible/inventories/production/hosts | awk '{print $2}' | cut -d'=' -f2)

if [ -n "$HOST_IP" ]; then
    echo "Testing API endpoints on $HOST_IP..."
    
    # Wait a moment for services to start
    sleep 10
    
    # Test health endpoint
    if curl -f -s http://$HOST_IP/health >/dev/null; then
        echo "✅ Health endpoint working"
    else
        echo "⚠️ Health endpoint not responding yet"
    fi
    
    # Test users endpoint
    if curl -f -s http://$HOST_IP/users >/dev/null; then
        echo "✅ Users endpoint working"
    else
        echo "⚠️ Users endpoint not responding yet"
    fi
    
    echo ""
    echo "🎉 Deployment complete!"
    echo "Access your API at:"
    echo "  Health: http://$HOST_IP/health"
    echo "  Users:  http://$HOST_IP/users"
else
    echo "⚠️ Could not determine server IP for testing"
fi

echo ""
echo "📝 To clean up prepared files, run: rm -f ansible/roles/golang-app/files/{main.go,Dockerfile,go.mod}" 