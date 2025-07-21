# Docker Deployment Troubleshooting Guide

## 🐛 Common Docker Service Issues

### Issue: "Unable to start service docker: Job for docker.service failed"

This error typically occurs when:
- Running in containerized environments (GitHub Actions, Docker-in-Docker)
- systemd is not properly initialized
- Permission issues with Docker daemon
- Conflicting Docker installations

### 🔧 Our Automated Fixes

The Ansible playbook now includes several fallback mechanisms:

1. **Systemd Service Start** (Primary)
   ```bash
   systemctl start docker
   systemctl enable docker
   ```

2. **Alternative Service Start** (Fallback #1)
   ```bash
   service docker start
   ```

3. **Direct Daemon Start** (Fallback #2)
   ```bash
   dockerd --config-file=/etc/docker/daemon.json &
   ```

4. **CI Environment Detection**
   - Automatically detects GitHub Actions environment
   - Uses specialized startup sequence for CI/CD

### 🔍 Manual Troubleshooting Commands

If Docker still fails to start, try these commands on your server:

```bash
# Check Docker service status
systemctl status docker

# View Docker logs
journalctl -xeu docker.service

# Check if Docker daemon is running
ps aux | grep docker

# Test Docker socket
ls -la /var/run/docker.sock

# Check Docker daemon configuration
cat /etc/docker/daemon.json

# Try starting Docker manually
sudo dockerd --debug

# Check system resources
df -h
free -h
```

### 🚀 GitHub Actions Specific Issues

**Environment Variables Checked:**
- `CI`: Present in most CI environments
- `GITHUB_ACTIONS`: Specific to GitHub Actions

**Common Solutions:**
1. **Use Docker-in-Docker**: Already handled by our setup
2. **Permission Issues**: Socket permissions are automatically fixed
3. **Service Manager**: Falls back to direct daemon start

### 🛠️ Local Testing Commands

Test the Docker role independently:
```bash
ansible-playbook ansible/playbooks/setup-infrastructure.yml --tags "docker" -v
```

Test Docker functionality after installation:
```bash
# On the target server
docker --version
docker info
docker run hello-world
```

### 📊 Expected Deployment Flow

1. ✅ **Remove old Docker versions**
2. ✅ **Add Docker GPG key and repository**
3. ✅ **Install Docker CE packages**
4. ⚠️ **Start Docker service** (May fail in CI)
5. ✅ **Alternative startup methods** (Automatic fallback)
6. ✅ **Verify Docker functionality**
7. ✅ **Configure Docker daemon**

### 🔄 Recovery Steps

If the deployment fails at Docker startup:

1. **Check the deployment logs** for specific error messages
2. **SSH into the server** and run manual troubleshooting commands
3. **Re-run just the Docker role**:
   ```bash
   ansible-playbook ansible/playbooks/setup-infrastructure.yml --tags "docker" --limit webservers
   ```

### 🌐 Environment-Specific Notes

**GitHub Actions:**
- Uses Ubuntu runners with systemd limitations
- Our playbook detects this and uses direct daemon startup
- Extended sleep times for initialization

**DigitalOcean Droplets:**
- Usually work well with systemd
- Ensure UFW allows Docker traffic
- Check for sufficient disk space

**Docker Hub Rate Limits:**
- May affect image pulls during deployment
- Consider using authenticated pulls for production

### 📝 Success Indicators

Look for these messages in the deployment output:
```
✅ Docker version: Docker version 28.x.x
✅ Docker daemon status: Running
✅ Docker image builds successfully
```

### 🆘 Emergency Docker Recovery

If Docker is completely broken:
```bash
# Complete Docker removal and reinstall
sudo apt purge docker-ce docker-ce-cli containerd.io
sudo rm -rf /var/lib/docker
sudo rm -rf /etc/docker

# Re-run Ansible Docker role
ansible-playbook ansible/playbooks/setup-infrastructure.yml --tags "docker"
```

## 🌐 Other Common Issues

### Nginx Configuration Errors

**Issue: "invalid parameter 'off' in nginx config"**
- **Cause**: Invalid Nginx directive syntax
- **Fix**: Already resolved in our templates
- **Test**: `nginx -t` on the server

**Issue: "nginx: configuration file test failed"**
- **Manual Fix**:
  ```bash
  # Test nginx config
  sudo nginx -t
  
  # Check specific file
  sudo nginx -t -c /etc/nginx/sites-available/users-api
  
  # View nginx error logs
  sudo tail -f /var/log/nginx/error.log
  ```

## 📞 Need Help?

1. Check the deployment logs first
2. Run our test script: `./test-deployment.sh`
3. Try manual troubleshooting commands above
4. Check GitHub Actions logs for specific error messages 