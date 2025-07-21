# Go API Ansible Deployment

A production-ready deployment setup for a Go REST API using Ansible, Docker, and Nginx.

## 🏗️ Architecture Overview

This project deploys a simple Go REST API that serves user data. The architecture includes:

- **Go Application**: Simple REST API with `/users` and `/health` endpoints
- **Docker**: Containerized application deployment
- **Nginx**: Reverse proxy with rate limiting and SSL termination
- **Ansible**: Infrastructure as Code for automated deployments
- **GitHub Actions**: CI/CD pipeline for automated testing and deployment

## 📁 Project Structure

```
ansible/
├── ansible.cfg                    # Ansible configuration
├── inventories/
│   └── production/
│       ├── hosts                  # Server inventory
│       └── group_vars/
│           ├── all.yml           # Global variables
│           └── webservers.yml    # Web server specific variables
├── playbooks/
│   ├── site.yml                  # Master playbook
│   ├── setup-infrastructure.yml  # Infrastructure setup
│   └── deploy-app.yml            # Application deployment
└── roles/
    ├── common/                   # Base server configuration
    ├── docker/                   # Docker installation & config
    ├── nginx/                    # Nginx reverse proxy setup
    └── golang-app/              # Go application deployment
```

## 🚀 What Each Component Does

### 📋 **Playbooks**
- **site.yml**: Orchestrates the complete deployment process
- **setup-infrastructure.yml**: Installs and configures system dependencies
- **deploy-app.yml**: Handles application deployment and updates

### 🎭 **Roles**
- **common**: Essential server setup (packages, firewall, timezone)
- **docker**: Docker CE installation and configuration  
- **nginx**: Reverse proxy with security headers and rate limiting
- **golang-app**: Go application containerization and deployment

### 📊 **Inventory & Variables**
- **hosts**: Defines server groups and connection details
- **group_vars/**: Configuration variables organized by server groups

## 🛠️ Local Testing & Development

### Prerequisites
- Ansible 2.9+
- Python 3.8+
- SSH access to target servers

### Test Syntax
```bash
cd ansible
ansible-playbook --syntax-check playbooks/site.yml
```

### Test Connection
```bash
cd ansible  
ansible webservers -m ping
```

### Full Deployment
```bash
cd ansible
ansible-playbook playbooks/site.yml -v
```

### Deploy Only App (Skip Infrastructure)
```bash
cd ansible
ansible-playbook playbooks/deploy-app.yml --tags "app"
```

## 🤖 GitHub Actions CI/CD

The project includes a complete CI/CD pipeline that:

1. **Tests**: Runs Go tests and builds the application
2. **Deploys**: Uses Ansible to deploy to production servers
3. **Verifies**: Tests deployed endpoints to ensure successful deployment

### Required GitHub Secrets

Set these in your repository settings:

| Secret | Description | Example |
|--------|-------------|---------|
| `SSH_PRIVATE_KEY` | Private SSH key for server access | `-----BEGIN OPENSSH PRIVATE KEY-----...` |
| `HOST` | Target server IP address | `64.226.109.101` |
| `USER` | SSH username for the server | `root` |

### Workflow Triggers
- **Push to main**: Triggers full test + deploy pipeline
- **Pull requests**: Runs tests only

## 🔧 Server Configuration

### Ports Used
- **22**: SSH access
- **80**: HTTP (Nginx reverse proxy)
- **443**: HTTPS (if SSL enabled)
- **8080**: Go application (localhost only)

### Security Features
- UFW firewall configuration
- Nginx security headers
- Rate limiting (10 requests/second)
- Docker container isolation
- Non-root application user

### Monitoring & Logging
- Application logs in `/var/log/users-api/`
- Nginx access/error logs
- Docker container logs
- Automatic log rotation

## 🎯 API Endpoints

Once deployed, your API will be available at:

- **Health Check**: `http://your-server-ip/health`
- **Users List**: `http://your-server-ip/users`

Example response from `/users`:
```json
[
  {"id": 1, "name": "John Doe", "email": "john@example.com"},
  {"id": 2, "name": "Jane Smith", "email": "jane@example.com"},
  {"id": 3, "name": "Bob Johnson", "email": "bob@example.com"}
]
```

## 🔄 Deployment Process

The deployment follows this sequence:

1. **Infrastructure Setup**:
   - Update system packages
   - Configure firewall
   - Install Docker
   - Setup Nginx with reverse proxy

2. **Application Deployment**:
   - Create application user and directories
   - Build Docker image from source
   - Deploy container with health checks
   - Verify endpoints are responding

3. **Verification**:
   - Test API health endpoint
   - Validate user data endpoint
   - Confirm Nginx proxy is working

## 🐛 Troubleshooting

### Common Issues

**Docker Service Startup Issues**:
The most common deployment issue is Docker failing to start in CI environments. Our playbook includes automatic fallbacks, but if you encounter:
```
Unable to start service docker: Job for docker.service failed
```
See detailed solutions in [DOCKER_TROUBLESHOOTING.md](DOCKER_TROUBLESHOOTING.md).

**Connection Issues**:
```bash
# Test SSH connectivity
ssh -i ~/.ssh/your-key user@your-server

# Test Ansible connectivity
ansible webservers -m ping -v
```

**Application Not Responding**:
```bash
# Check container status
docker ps
docker logs users-api

# Check Nginx status
systemctl status nginx
nginx -t
```

**Permission Issues**:
```bash
# Check application user
id users-api

# Check file permissions
ls -la /opt/users-api/
```

## 📈 Scaling Considerations

For production scaling, consider:

- **Multiple App Servers**: Add more servers to the `webservers` group
- **Load Balancing**: Configure Nginx upstream with multiple backends
- **Database**: Uncomment and configure the `database` group
- **Monitoring**: Enable the `monitoring` group for metrics collection
- **SSL/TLS**: Set `ssl_enabled: true` in group variables

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Test changes locally with `ansible-playbook --check`
4. Submit a pull request

## 📝 License

MIT License - see LICENSE file for details
