# 2️⃣ Server Software Setup

**Run after completing 1-EC2-SETUP.md** - Installs all required software on your EC2 instance.

## 🎯 What You'll Install
- Python 3.11+
- Node.js 18+ & npm
- Git
- Nginx (for production)
- PM2 (process manager)

## 🚀 Installation Commands

### 1. Install Python 3.11
```bash
# Add deadsnakes PPA for latest Python
sudo add-apt-repository ppa:deadsnakes/ppa -y
sudo apt update

# Install Python 3.11 and pip
sudo apt install python3.11 python3.11-venv python3.11-dev python3-pip -y

# Create symlink for easier access
sudo update-alternatives --install /usr/bin/python3 python3 /usr/bin/python3.11 1
```

### 2. Install Node.js 18+
```bash
# Install Node.js via NodeSource repository
curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -
sudo apt-get install -y nodejs

# Verify installation
node --version  # Should show v18.x.x or higher
npm --version   # Should show npm version
```

### 3. Install Essential Tools
```bash
# Install Git, curl, and other essentials
sudo apt install git curl unzip tree htop -y

# Install Nginx for production serving
sudo apt install nginx -y

# Install PM2 for process management
sudo npm install -g pm2
```

### 4. Configure Firewall (Optional but recommended)
```bash
# Enable UFW firewall
sudo ufw enable

# Allow necessary ports
sudo ufw allow ssh
sudo ufw allow 'Nginx Full'
sudo ufw allow 8000
sudo ufw allow 5173

# Check status
sudo ufw status
```

## 🔍 Verify Installation

Run these commands to verify everything is installed correctly:

```bash
# Check versions
python3 --version    # Should be 3.11.x
node --version       # Should be v18.x.x+
npm --version        # Should show npm version
git --version        # Should show git version
nginx -v            # Should show nginx version
pm2 --version       # Should show PM2 version

# Check services
sudo systemctl status nginx
```

Expected output:
```
python3 --version
Python 3.11.7

node --version  
v18.19.0

nginx -v
nginx version: nginx/1.18.0
```

## ✅ Verification Checklist
- [ ] Python 3.11+ installed
- [ ] Node.js 18+ installed  
- [ ] Git installed
- [ ] Nginx installed and running
- [ ] PM2 installed globally
- [ ] Firewall configured (if using UFW)

## 🔄 Next Step
Continue to **`3-CODE-DEPLOYMENT.md`** to clone and set up the Notes app.