#!/bin/bash

# User Data Script for Web Servers
# This script runs when EC2 instance launches

# Log output for debugging
exec > >(tee /var/log/user-data.log)
exec 2>&1

echo "========================================"
echo "Starting User Data Script"
echo "Time: $(date)"
echo "========================================"

# Update system packages
echo "Updating system packages..."
yum update -y

# Install Apache web server and MySQL client
echo "Installing Apache and MySQL client..."
yum install -y httpd mariadb105

# Start and enable Apache
echo "Starting Apache web server..."
systemctl start httpd
systemctl enable httpd

# Create health check file for Load Balancer
echo "Creating health check endpoint..."
echo "OK" > /var/www/html/health

# Create simple web page
echo "Creating web page..."
cat > /var/www/html/index.html <<'EOF'
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>AWS Multi-Tier App</title>
    <style>
        body {
            font-family: Arial, sans-serif;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            display: flex;
            justify-content: center;
            align-items: center;
            height: 100vh;
            margin: 0;
        }
        .container {
            background: white;
            padding: 40px;
            border-radius: 10px;
            box-shadow: 0 10px 25px rgba(0,0,0,0.2);
            text-align: center;
            max-width: 500px;
        }
        h1 {
            color: #FF9900;
            margin-bottom: 20px;
        }
        .info-box {
            background: #f5f5f5;
            padding: 15px;
            border-radius: 5px;
            margin: 10px 0;
            border-left: 4px solid #FF9900;
        }
        .label {
            font-weight: bold;
            color: #333;
        }
        .value {
            color: #666;
            font-family: monospace;
        }
    </style>
</head>
<body>
    <div class="container">
        <h1>🚀 Multi-Tier Web Application</h1>
        <p>Successfully deployed on AWS!</p>
        
        <div class="info-box">
            <div class="label">Server:</div>
            <div class="value">HOSTNAME_PLACEHOLDER</div>
        </div>
        
        <div class="info-box">
            <div class="label">Private IP:</div>
            <div class="value">IP_PLACEHOLDER</div>
        </div>
        
        <div class="info-box">
            <div class="label">Status:</div>
            <div class="value">✅ Running</div>
        </div>
        
        <p style="margin-top: 30px; color: #666;">
            <small>Architecture: ALB → EC2 → RDS</small>
        </p>
    </div>
</body>
</html>
EOF

# Replace placeholders with actual values
HOSTNAME=$(hostname)
PRIVATE_IP=$(hostname -I | awk '{print $1}')

sed -i "s/HOSTNAME_PLACEHOLDER/$HOSTNAME/g" /var/www/html/index.html
sed -i "s/IP_PLACEHOLDER/$PRIVATE_IP/g" /var/www/html/index.html

# Set proper permissions
chmod 644 /var/www/html/index.html
chmod 644 /var/www/html/health

# Verify Apache is running
if systemctl is-active --quiet httpd; then
    echo "✓ Apache is running successfully"
else
    echo "✗ Apache failed to start"
    systemctl status httpd
fi

echo "========================================"
echo "User Data Script Completed"
echo "Time: $(date)"
echo "========================================"
