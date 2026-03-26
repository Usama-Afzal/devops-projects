#!/bin/bash

# Manual Web Server Setup Script
# Use this if user-data doesn't work or for manual installation

echo "========================================"
echo "Manual Web Server Setup"
echo "========================================"

# Check if running as root
if [ "$EUID" -ne 0 ]; then 
    echo "Please run as root (use sudo)"
    exit 1
fi

# Update system
echo "Step 1: Updating system..."
yum update -y

# Install packages
echo "Step 2: Installing Apache and MySQL client..."
yum install -y httpd mariadb105

# Start Apache
echo "Step 3: Starting Apache..."
systemctl start httpd
systemctl enable httpd

# Create health check
echo "Step 4: Creating health check endpoint..."
echo "OK" > /var/www/html/health

# Create index page
echo "Step 5: Creating web page..."
HOSTNAME=$(hostname)
PRIVATE_IP=$(hostname -I | awk '{print $1}')

cat > /var/www/html/index.html <<EOF
<!DOCTYPE html>
<html>
<head>
    <title>AWS Web Server</title>
    <style>
        body {
            font-family: Arial, sans-serif;
            margin: 40px;
            background-color: #f0f0f0;
        }
        .container {
            background: white;
            padding: 30px;
            border-radius: 8px;
            box-shadow: 0 2px 4px rgba(0,0,0,0.1);
        }
        h1 { color: #FF9900; }
        .info { 
            background: #f5f5f5; 
            padding: 10px; 
            margin: 10px 0;
            border-radius: 4px;
        }
    </style>
</head>
<body>
    <div class="container">
        <h1>✅ Web Server Active</h1>
        <div class="info"><strong>Hostname:</strong> $HOSTNAME</div>
        <div class="info"><strong>Private IP:</strong> $PRIVATE_IP</div>
        <div class="info"><strong>Status:</strong> Running</div>
        <p>This server is part of an AWS Multi-Tier Architecture</p>
    </div>
</body>
</html>
EOF

# Set permissions
chmod 644 /var/www/html/index.html
chmod 644 /var/www/html/health

# Test Apache
echo "Step 6: Testing Apache..."
if systemctl is-active --quiet httpd; then
    echo "✓ Apache is running"
    curl -s http://localhost/health
else
    echo "✗ Apache is not running"
    exit 1
fi

echo "========================================"
echo "Setup completed successfully!"
echo "========================================"
