#!/bin/bash

# EC2 RHEL 9 Dependencies Installation Script
# This script installs all necessary dependencies for the notes application

set -e  # Exit on any error

echo "🚀 Starting dependency installation on RHEL 9..."

# Update system packages
echo "📦 Updating system packages..."
sudo dnf update -y

# Install development tools
echo "🔧 Installing development tools..."
sudo dnf groupinstall -y "Development Tools"
sudo dnf install -y git curl wget

# Install Python 3.11 and pip
echo "🐍 Installing Python 3.11..."
sudo dnf install -y python3.11 python3.11-pip python3.11-devel

# Create symbolic links for python and pip
sudo alternatives --install /usr/bin/python python /usr/bin/python3.11 1
sudo alternatives --install /usr/bin/pip pip /usr/bin/pip3.11 1

# Install MariaDB
echo "🗄️ Installing MariaDB..."
sudo dnf install -y mariadb-server mariadb-devel
sudo systemctl start mariadb
sudo systemctl enable mariadb

# Install additional packages for Python MySQL connectivity
echo "🔗 Installing MySQL client libraries..."
sudo dnf install -y mysql-devel pkg-config

# Install Node.js and npm for frontend building
echo "⚡ Installing Node.js..."
curl -fsSL https://rpm.nodesource.com/setup_18.x | sudo bash -
sudo dnf install -y nodejs

# Install PM2 for process management
echo "🔄 Installing PM2..."
sudo npm install -g pm2

# Install Nginx for reverse proxy
echo "🌐 Installing Nginx..."
sudo dnf install -y nginx
sudo systemctl enable nginx

# Create application user
echo "👤 Creating application user..."
sudo useradd -m -s /bin/bash notes_app || echo "User already exists"
sudo usermod -aG wheel notes_app

# Create application directory
echo "📁 Creating application directories..."
sudo mkdir -p /opt/notes_app
sudo chown notes_app:notes_app /opt/notes_app

# Create backup directory
echo "💾 Creating backup directory..."
sudo mkdir -p /backup
sudo chown notes_app:notes_app /backup

echo "✅ All dependencies installed successfully!"
echo "🔑 Next steps:"
echo "   1. Secure MariaDB installation: sudo mysql_secure_installation"
echo "   2. Deploy the application files"
echo "   3. Configure the database"
echo "   4. Start the services"