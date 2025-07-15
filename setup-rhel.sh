#!/bin/bash
# RHEL Setup Script for Notes App
# This script sets up the Notes App on RHEL/CentOS systems

set -e  # Exit on any error

echo "🔧 Notes App - RHEL Setup Script"
echo "=================================="

# Detect RHEL version and package manager
if command -v dnf &> /dev/null; then
    PKG_MGR="dnf"
    RHEL_VERSION="8+"
elif command -v yum &> /dev/null; then
    PKG_MGR="yum"
    RHEL_VERSION="7"
else
    echo "❌ Error: Neither dnf nor yum found. This script is for RHEL/CentOS systems."
    exit 1
fi

echo "📍 Detected: RHEL $RHEL_VERSION using $PKG_MGR"
echo ""

# Function to check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Function to install packages
install_packages() {
    echo "📦 Installing packages: $*"
    sudo $PKG_MGR install -y "$@"
}

# Update system
echo "🔄 Updating system packages..."
sudo $PKG_MGR update -y

# Install EPEL repository if not present
if ! $PKG_MGR repolist | grep -q epel; then
    echo "📦 Installing EPEL repository..."
    install_packages epel-release
fi

# Install development tools
echo "🔧 Installing development tools..."
sudo $PKG_MGR groupinstall -y "Development Tools"
install_packages gcc gcc-c++ make git

# Install Python 3
echo "🐍 Setting up Python..."
if ! command_exists python3; then
    if [ "$RHEL_VERSION" = "8+" ]; then
        install_packages python3 python3-pip python3-devel
    else
        # RHEL 7 - may need Software Collections for newer Python
        install_packages python3 python3-pip python3-devel
    fi
else
    echo "✅ Python 3 already installed: $(python3 --version)"
fi

# Install Node.js and npm
echo "📦 Setting up Node.js..."
if ! command_exists node; then
    if [ "$RHEL_VERSION" = "8+" ]; then
        # Try to install from EPEL first
        install_packages nodejs npm
    else
        # For RHEL 7, install from EPEL
        install_packages nodejs npm
    fi
    
    # Verify Node.js version
    NODE_VERSION=$(node --version | cut -d'v' -f2 | cut -d'.' -f1)
    if [ "$NODE_VERSION" -lt 18 ]; then
        echo "⚠️  Warning: Node.js version is $NODE_VERSION. Version 18+ is recommended."
        echo "   Consider installing from NodeSource repository:"
        echo "   curl -fsSL https://rpm.nodesource.com/setup_18.x | sudo bash -"
        echo "   sudo $PKG_MGR install nodejs"
    fi
else
    echo "✅ Node.js already installed: $(node --version)"
fi

# Install additional dependencies for Python packages
echo "🔧 Installing additional build dependencies..."
if [ "$RHEL_VERSION" = "8+" ]; then
    install_packages openssl-devel libffi-devel sqlite-devel
else
    install_packages openssl-devel libffi-devel sqlite-devel
fi

# Setup backend
echo "🏗️  Setting up backend..."
cd backend

# Create virtual environment if it doesn't exist
if [ ! -d "venv" ]; then
    echo "📦 Creating Python virtual environment..."
    python3 -m venv venv
fi

# Activate virtual environment and install dependencies
echo "📦 Installing Python dependencies..."
source venv/bin/activate
pip install --upgrade pip
pip install -r requirements.txt

cd ..

# Setup frontend
echo "🎨 Setting up frontend..."
cd frontend

echo "📦 Installing Node.js dependencies..."
npm install

cd ..

# Configure firewall (if needed)
if systemctl is-active --quiet firewalld; then
    echo "🔥 Configuring firewall..."
    sudo firewall-cmd --permanent --add-port=8000/tcp --quiet || true
    sudo firewall-cmd --permanent --add-port=5173/tcp --quiet || true
    sudo firewall-cmd --reload --quiet || true
    echo "✅ Firewall ports opened for development (8000, 5173)"
fi

# Check SELinux status
if command_exists sestatus; then
    SELINUX_STATUS=$(sestatus | grep "Current mode" | awk '{print $3}')
    if [ "$SELINUX_STATUS" = "enforcing" ]; then
        echo "⚠️  SELinux is in enforcing mode. If you encounter permission issues:"
        echo "   sudo setenforce 0  # Temporarily disable"
        echo "   See RHEL_SETUP_GUIDE.md for more information"
    fi
fi

echo ""
echo "🎉 Setup completed successfully!"
echo ""
echo "📋 Next steps:"
echo "   1. Start the development servers:"
echo "      npm run dev"
echo ""
echo "   2. Access the application:"
echo "      - Frontend: http://localhost:5173"
echo "      - Backend API: http://localhost:8000"
echo "      - API Docs: http://localhost:8000/docs"
echo ""
echo "📖 For more information, see:"
echo "   - README.md - General project information"
echo "   - DEVELOPMENT.md - Development guide"
echo "   - RHEL_SETUP_GUIDE.md - RHEL-specific setup details"
echo ""
echo "🔧 For troubleshooting RHEL-specific issues, check RHEL_SETUP_GUIDE.md"