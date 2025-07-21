# Create the structure
mkdir -p ansible-deployment && cd ansible-deployment

# Test connection
ansible all -m ping

# Full deployment
ansible-playbook playbooks/site.yml -v

# Deploy only app updates
ansible-playbook playbooks/deploy-app.yml --tags "app"