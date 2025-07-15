# 1️⃣ EC2 Instance Setup

**Follow this guide first** - Sets up your AWS EC2 instance for the Notes app.

## 🎯 What You'll Do
- Launch an EC2 instance
- Configure security groups  
- Connect to your instance

## 📋 Prerequisites
- AWS account with EC2 access
- Basic terminal knowledge

## 🚀 Step-by-Step Instructions

### 1. Launch EC2 Instance

1. **Go to AWS Console** → EC2 Dashboard
2. **Click "Launch Instance"**
3. **Configure your instance:**
   - **Name**: `notes-app-server`
   - **AMI**: Ubuntu Server 22.04 LTS (Free tier eligible)
   - **Instance Type**: `t2.micro` (Free tier) or `t3.small` (recommended)
   - **Key Pair**: Create new or select existing
   - **Storage**: 20 GB gp3 (default is fine)

### 2. Configure Security Group

Create a security group with these inbound rules:

| Type | Protocol | Port Range | Source | Description |
|------|----------|------------|--------|-------------|
| SSH | TCP | 22 | Your IP | SSH access |
| HTTP | TCP | 80 | 0.0.0.0/0 | Frontend access |
| HTTPS | TCP | 443 | 0.0.0.0/0 | Secure frontend |
| Custom TCP | TCP | 8000 | 0.0.0.0/0 | Backend API |
| Custom TCP | TCP | 5173 | 0.0.0.0/0 | Frontend dev (optional) |

### 3. Launch and Connect

1. **Launch the instance**
2. **Wait for status checks** to pass (2-3 minutes)
3. **Connect via SSH:**
   ```bash
   chmod 400 your-key.pem
   ssh -i your-key.pem ubuntu@your-ec2-public-ip
   ```

### 4. Update System
Once connected, run:
```bash
sudo apt update && sudo apt upgrade -y
```

## ✅ Verification
- [ ] EC2 instance is running
- [ ] Security group allows necessary ports
- [ ] You can SSH into the instance
- [ ] System is updated

## 🔄 Next Step
Continue to **`2-SERVER-SETUP.md`** to install required software.