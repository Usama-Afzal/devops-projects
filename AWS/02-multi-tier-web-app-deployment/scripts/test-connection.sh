#!/bin/bash

# Database Connection Test Script
# Run this from a web server to test RDS connection

# Colors for output
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo "========================================"
echo "Database Connection Test"
echo "========================================"

# Get RDS endpoint (you need to provide this)
read -p "Enter RDS endpoint: " RDS_ENDPOINT
read -p "Enter database username (default: admin): " DB_USER
DB_USER=${DB_USER:-admin}
read -sp "Enter database password: " DB_PASS
echo

# Test connection
echo "Testing connection to $RDS_ENDPOINT..."

mysql -h "$RDS_ENDPOINT" -u "$DB_USER" -p"$DB_PASS" -e "SELECT 'Connection successful!' AS Status;" 2>/dev/null

if [ $? -eq 0 ]; then
    echo -e "${GREEN}✓ Database connection successful!${NC}"
    
    # Test query
    echo "Running test query..."
    mysql -h "$RDS_ENDPOINT" -u "$DB_USER" -p"$DB_PASS" -e "SHOW DATABASES;" 2>/dev/null
else
    echo -e "${RED}✗ Database connection failed!${NC}"
    echo "Please check:"
    echo "1. RDS endpoint is correct"
    echo "2. Username and password are correct"
    echo "3. Security group allows connection from this server"
    exit 1
fi

echo "========================================"
