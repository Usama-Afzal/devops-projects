# Troubleshooting Guide

## Common Issues and Solutions

### 1. Load Balancer Returning 504 Error

**Symptoms:**
- Browser shows 504 Gateway Timeout
- Targets showing "Unhealthy"

**Causes:**
- Security groups blocking traffic
- Apache not running
- Health check file missing

**Solutions:**
1. Check WebServer-SG allows HTTP from ALB-SG
2. SSH to server and run: `sudo systemctl status httpd`
3. Verify `/var/www/html/health` exists

