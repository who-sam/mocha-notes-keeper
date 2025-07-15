# RHEL Setup Guide

This guide provides RHEL-compatible commands for setting up the Notes App project.

## Package Manager Commands Translation

### Basic Package Management

| Ubuntu/Debian (apt) | RHEL 8+ (dnf) | RHEL 7 (yum) |
|---------------------|---------------|--------------|
| `apt update` | `dnf update` | `yum update` |
| `apt install <package>` | `dnf install <package>` | `yum install <package>` |
| `apt remove <package>` | `dnf remove <package>` | `yum remove <package>` |
| `apt search <package>` | `dnf search <package>` | `yum search <package>` |
| `apt list --installed` | `dnf list installed` | `yum list installed` |

## System Prerequisites for RHEL

### 1. Enable EPEL Repository (if needed)
```bash
# RHEL 8+
sudo dnf install epel-release

# RHEL 7
sudo yum install epel-release
```

### 2. Install Development Tools
```bash
# RHEL 8+
sudo dnf groupinstall "Development Tools"
sudo dnf install gcc gcc-c++ make

# RHEL 7
sudo yum groupinstall "Development Tools"
sudo yum install gcc gcc-c++ make
```

### 3. Install Python 3.11+ (if not available)
```bash
# RHEL 8+
sudo dnf install python3.11 python3.11-pip python3.11-devel

# RHEL 7 (may need Software Collections)
sudo yum install centos-release-scl
sudo yum install rh-python311 rh-python311-python-pip
```

### 4. Install Node.js 18+
```bash
# Option 1: Using NodeSource repository
curl -fsSL https://rpm.nodesource.com/setup_18.x | sudo bash -
sudo dnf install nodejs  # or yum for RHEL 7

# Option 2: Using DNF/YUM modules (RHEL 8+)
sudo dnf module install nodejs:18

# Option 3: Using EPEL
sudo dnf install nodejs npm
```

## PostgreSQL Setup (RHEL)

If using PostgreSQL instead of SQLite:

### RHEL 8+
```bash
# Install PostgreSQL
sudo dnf install postgresql postgresql-server postgresql-devel

# Initialize database
sudo postgresql-setup --initdb

# Start and enable service
sudo systemctl start postgresql
sudo systemctl enable postgresql

# Install Python PostgreSQL adapter dependencies
sudo dnf install python3-devel libpq-devel
```

### RHEL 7
```bash
# Install PostgreSQL
sudo yum install postgresql postgresql-server postgresql-devel

# Initialize database
sudo postgresql-setup initdb

# Start and enable service
sudo systemctl start postgresql
sudo systemctl enable postgresql

# Install Python PostgreSQL adapter dependencies
sudo yum install python3-devel postgresql-devel
```

## Common System Dependencies

### For building Python packages (if needed)
```bash
# RHEL 8+
sudo dnf install gcc gcc-c++ make python3-devel openssl-devel libffi-devel

# RHEL 7
sudo yum install gcc gcc-c++ make python3-devel openssl-devel libffi-devel
```

### For SQLite development (usually pre-installed)
```bash
# RHEL 8+
sudo dnf install sqlite-devel

# RHEL 7
sudo yum install sqlite-devel
```

## Docker Setup on RHEL

### RHEL 8+
```bash
# Install Docker
sudo dnf config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
sudo dnf install docker-ce docker-ce-cli containerd.io

# Or use Podman (Red Hat's container engine)
sudo dnf install podman podman-compose
```

### RHEL 7
```bash
# Install Docker
sudo yum install -y yum-utils
sudo yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
sudo yum install docker-ce docker-ce-cli containerd.io
```

## Updated Dockerfile for RHEL-based Images

If you need to use RHEL-based container images:

```dockerfile
# Option 1: Using official RHEL UBI (Universal Base Image)
FROM registry.access.redhat.com/ubi8/python-39

# Option 2: Using CentOS (free RHEL-compatible)
FROM centos:8

# Install system dependencies
RUN dnf update -y && \
    dnf install -y python3 python3-pip && \
    dnf clean all

WORKDIR /app
COPY requirements.txt .
RUN pip3 install -r requirements.txt

COPY . .
EXPOSE 8000

CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8000"]
```

## Firewall Configuration (RHEL)

```bash
# Open ports for development
sudo firewall-cmd --permanent --add-port=8000/tcp  # Backend
sudo firewall-cmd --permanent --add-port=5173/tcp  # Frontend
sudo firewall-cmd --reload

# Or disable firewall for development (not recommended for production)
sudo systemctl stop firewalld
sudo systemctl disable firewalld
```

## SELinux Considerations

If you encounter permission issues:

```bash
# Check SELinux status
sestatus

# Temporarily disable SELinux (development only)
sudo setenforce 0

# Permanently disable SELinux (edit /etc/selinux/config)
sudo sed -i 's/SELINUX=enforcing/SELINUX=disabled/' /etc/selinux/config
```

## Quick Setup Script for RHEL

Create a setup script:

```bash
#!/bin/bash
# setup-rhel.sh

# Detect RHEL version
if command -v dnf &> /dev/null; then
    PKG_MGR="dnf"
else
    PKG_MGR="yum"
fi

echo "Using package manager: $PKG_MGR"

# Install basic dependencies
sudo $PKG_MGR update -y
sudo $PKG_MGR install -y python3 python3-pip nodejs npm git

# Install development tools
sudo $PKG_MGR groupinstall -y "Development Tools"

# Setup project
cd backend
python3 -m venv venv
source venv/bin/activate
pip install -r requirements.txt

cd ../frontend
npm install

echo "Setup complete! Run 'npm run dev' to start the application."
```

## Notes for Migration

1. **Python Path**: On RHEL, Python 3 might be `python3` instead of `python`
2. **pip Command**: Use `pip3` instead of `pip` if needed
3. **Virtual Environment**: Always use virtual environments on RHEL
4. **Permissions**: RHEL has stricter security policies (SELinux)
5. **Firewall**: RHEL has firewalld enabled by default

## Verification Commands

```bash
# Check installed versions
python3 --version
node --version
npm --version

# Check services
systemctl status postgresql  # if using PostgreSQL
systemctl status firewalld
```

This guide should help you adapt any Ubuntu/Debian scripts to work properly on RHEL systems.