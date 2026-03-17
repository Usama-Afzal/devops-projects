#!/bin/bash
yum update -y
yum install -y nginx
systemctl start nginx
systemctl enable nginx
echo "<h1>Hello from EC2 - Nginx Web Server</h1>" > /usr/share/nginx/html/index.html
