# AWS Infrastructure Setup Checklist

Before deploying the Notes application, ensure your AWS infrastructure is properly configured.

## ✅ EC2 Instance Setup

### 1. Launch EC2 Instance

- [ ] **AMI**: Red Hat Enterprise Linux 9 (RHEL 9)
- [ ] **Instance Type**: t2.micro (minimum) or larger
- [ ] **Key Pair**: Create or select an existing key pair for SSH access
- [ ] **Network**: Default VPC is fine, or use your custom VPC
- [ ] **Subnet**: Public subnet (for internet access)
- [ ] **Auto-assign Public IP**: Enabled
- [ ] **Storage**: 
  - [ ] Root volume: 8 GB GP3 (minimum)
  - [ ] Additional EBS volume for backups (optional size, but 10GB+ recommended)

### 2. Security Group Configuration

Create or modify security group with these rules:

#### Inbound Rules:
- [ ] **SSH (Port 22)**
  - Source: Your IP address or 0.0.0.0/0 (less secure)
  - Protocol: TCP
  - Port: 22

- [ ] **HTTP (Port 80)**
  - Source: 0.0.0.0/0 (public access)
  - Protocol: TCP
  - Port: 80

#### Outbound Rules:
- [ ] **All traffic** (default - allows internet access for package downloads)

### 3. Key Pair Setup

- [ ] Download the `.pem` private key file
- [ ] Set correct permissions: `chmod 400 your-key.pem`
- [ ] Test SSH connection:
  ```bash
  ssh -i your-key.pem ec2-user@your-ec2-public-dns
  ```

## 💾 EBS Volume for Backups

### Create Additional EBS Volume

- [ ] **Volume Type**: GP3 (recommended) or GP2
- [ ] **Size**: 10 GB minimum (adjust based on expected data growth)
- [ ] **Availability Zone**: Same as your EC2 instance
- [ ] **Encryption**: Enabled (recommended for production)

### Attach Volume to EC2 Instance

- [ ] Select the created volume in AWS Console
- [ ] Actions → Attach Volume
- [ ] Select your EC2 instance
- [ ] Note the device name (e.g., `/dev/sdf`, `/dev/xvdf`)

## 🌐 Network Configuration

### DNS and Public Access

- [ ] **Public DNS**: Note your instance's public DNS name
  - Format: `ec2-X-X-X-X.compute-1.amazonaws.com`
  - Update the domain in deployment scripts if different

- [ ] **Elastic IP** (Optional but recommended for production):
  - [ ] Allocate Elastic IP
  - [ ] Associate with your EC2 instance
  - [ ] Update DNS name in deployment scripts

## 🔐 Security Best Practices

### Instance Security

- [ ] **Security Group**: Restrict SSH access to your IP only
- [ ] **Key Management**: Store private key securely
- [ ] **Instance Metadata**: Use IMDSv2 (set during launch)

### Database Security

- [ ] **Password Policy**: Plan strong passwords for MariaDB
- [ ] **Backup Encryption**: EBS volume encryption enabled
- [ ] **Network Isolation**: Database only accessible from localhost

## 📝 Pre-Deployment Information Gathering

Collect this information before starting deployment:

### EC2 Instance Details
- [ ] **Instance ID**: `i-xxxxxxxxxx`
- [ ] **Public DNS**: `ec2-3-82-116-80.compute-1.amazonaws.com`
- [ ] **Private IP**: `10.x.x.x`
- [ ] **Availability Zone**: `us-east-1a` (example)

### EBS Volume Details
- [ ] **Volume ID**: `vol-xxxxxxxxxx`
- [ ] **Device Name**: `/dev/xvdf` (or whatever AWS assigned)
- [ ] **Size**: `10 GB`

### Security Group Details
- [ ] **Security Group ID**: `sg-xxxxxxxxxx`
- [ ] **Inbound Rules**: SSH (22), HTTP (80)

## 🚀 Ready to Deploy?

### Final Verification

- [ ] Can SSH into the instance
- [ ] Instance has internet connectivity
- [ ] EBS volume is attached
- [ ] Security groups allow HTTP/SSH
- [ ] Have administrative access to the instance

### Files to Upload to EC2

Upload these files to your EC2 instance before running deployment:

```bash
# Using SCP
scp -i your-key.pem -r /local/path/to/project ec2-user@your-ec2-dns:~/

# Or if using Git
ssh -i your-key.pem ec2-user@your-ec2-dns
git clone https://your-repo-url.git
```

## 📞 Common Issues and Solutions

### Can't Connect via SSH

- **Check Security Group**: Ensure port 22 is open to your IP
- **Key Permissions**: `chmod 400 your-key.pem`
- **User Name**: Use `ec2-user` for RHEL instances
- **Connection String**: `ssh -i key.pem ec2-user@public-dns`

### Instance Not Accessible from Internet

- **Public IP**: Ensure instance has public IP assigned
- **Route Tables**: Check if subnet route table has internet gateway
- **Security Groups**: Verify HTTP (port 80) is open

### EBS Volume Issues

- **Attachment**: Ensure volume is in same AZ as instance
- **Device Name**: Use the device name shown in AWS console
- **Permissions**: Volume should be attached, not just created

## 🎯 Next Steps

Once your AWS infrastructure is ready:

1. **Upload project files** to your EC2 instance
2. **Run the quick start script**: `sudo ./quick_start.sh`
3. **Follow the guided deployment process**
4. **Test your application** at your public DNS

---

**Need Help?** 
- Check AWS documentation for detailed EC2 setup instructions
- Use AWS Support if you have a support plan
- Review the main README for troubleshooting common deployment issues