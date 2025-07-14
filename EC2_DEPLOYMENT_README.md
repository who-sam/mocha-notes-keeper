# Notes Application EC2 Deployment Guide

## 🎯 Project Overview

This guide will help you deploy a complete notes application on AWS EC2 with the following components:

- **Frontend**: React/TypeScript application with modern UI
- **Backend**: FastAPI (Python) REST API
- **Database**: MariaDB for data persistence
- **Infrastructure**: RHEL 9 EC2 instance with EBS backup volume
- **Features**: Full CRUD operations for notes with timestamps

## 📋 Prerequisites

### AWS Infrastructure Requirements

1. **EC2 Instance**:
   - OS: RHEL 9
   - Type: t2.micro (or larger)
   - Key pair for SSH access
   - Public DNS: `ec2-3-82-116-80.compute-1.amazonaws.com`

2. **Security Groups**:
   - Port 22 (SSH) - for management
   - Port 80 (HTTP) - for web traffic

3. **EBS Volume**:
   - Additional volume for backups
   - Attached to EC2 instance

### Local Requirements

- SSH client
- Git (to clone this repository)

## 🚀 Quick Start Deployment

### Step 1: Connect to Your EC2 Instance

```bash
ssh -i your-key.pem ec2-user@ec2-3-82-116-80.compute-1.amazonaws.com
```

### Step 2: Clone and Upload Project Files

On your local machine, upload the project files to your EC2 instance:

```bash
# Option A: Using SCP
scp -i your-key.pem -r /path/to/this/project ec2-user@ec2-3-82-116-80.compute-1.amazonaws.com:~/

# Option B: Using Git (if you've pushed to a repository)
ssh -i your-key.pem ec2-user@ec2-3-82-116-80.compute-1.amazonaws.com
git clone https://your-repo-url.git
cd your-repo-name
```

### Step 3: Run Installation Script

```bash
sudo chmod +x deploy/install_dependencies.sh
sudo ./deploy/install_dependencies.sh
```

This script will install:
- Python 3.11
- MariaDB
- Node.js and npm
- Nginx
- PM2
- All required system dependencies

### Step 4: Secure MariaDB

```bash
sudo mysql_secure_installation
```

Follow the prompts:
- Set root password
- Remove anonymous users: **Y**
- Disallow root login remotely: **Y**
- Remove test database: **Y**
- Reload privilege tables: **Y**

### Step 5: Setup Database

```bash
sudo chmod +x deploy/mariadb_setup.sh
sudo ./deploy/mariadb_setup.sh
```

**Important**: When prompted for MariaDB root password, enter the password you set in Step 4.

### Step 6: Mount Backup Volume

```bash
sudo chmod +x deploy/mount_backup_volume.sh
sudo ./deploy/mount_backup_volume.sh
```

Follow the interactive prompts to:
- Select your EBS volume (e.g., `/dev/xvdf`)
- Format if needed (choose `ext4` or `xfs`)
- Mount to `/backup`
- Add to `/etc/fstab` for persistent mounting

### Step 7: Deploy Application

```bash
sudo chmod +x deploy/deploy_app.sh
sudo ./deploy/deploy_app.sh
```

This will:
- Set up Python virtual environment
- Install Python dependencies
- Build the frontend
- Configure Nginx
- Set up PM2 for process management
- Create systemd services
- Start all services

### Step 8: Setup Automated Backups

```bash
sudo chmod +x deploy/setup_backup_cron.sh
sudo ./deploy/setup_backup_cron.sh
```

Choose your backup frequency (recommended: daily at 2 AM).

### Step 9: Validate Deployment (Optional)

```bash
sudo ./final_check.sh
```

This comprehensive validation script checks all services, connectivity, database, backups, and security configurations to ensure everything is working correctly.

## 🌐 Accessing Your Application

After successful deployment:

- **Main Application**: http://ec2-3-82-116-80.compute-1.amazonaws.com
- **API Documentation**: http://ec2-3-82-116-80.compute-1.amazonaws.com/api/docs
- **Health Check**: http://ec2-3-82-116-80.compute-1.amazonaws.com/health

## 🔧 Management Commands

### Application Management

```bash
# Check application status
sudo systemctl status notes-app

# Restart application
sudo systemctl restart notes-app

# View application logs
sudo -u notes_app pm2 logs

# Check nginx status
sudo systemctl status nginx
```

### Database Management

```bash
# Check MariaDB status
sudo systemctl status mariadb

# Connect to database
mysql -u notes_user -p notes_db

# View database tables
mysql -u notes_user -p -e "USE notes_db; SHOW TABLES;"
```

### Backup Management

```bash
# Manual backup
sudo -u notes_app /opt/notes_app/deploy/backup_mariadb.sh

# List backups
ls -la /backup/mariadb/

# Restore from backup
sudo -u notes_app /opt/notes_app/deploy/restore_mariadb.sh

# Check backup logs
sudo tail -f /var/log/notes-backup.log
```

## 📊 Architecture Overview

```
Internet → AWS Security Group (Port 80) → EC2 Instance
                                           ├── Nginx (Reverse Proxy)
                                           ├── React Frontend (Static Files)
                                           ├── FastAPI Backend (Python)
                                           ├── MariaDB Database
                                           └── EBS Backup Volume (/backup)
```

### File Structure

```
/opt/notes_app/
├── backend/
│   ├── main_prod.py          # Production FastAPI app
│   ├── database_prod.py      # MariaDB configuration
│   ├── requirements-prod.txt # Production dependencies
│   ├── .env                  # Environment variables
│   └── venv/                 # Python virtual environment
├── frontend/
│   └── dist/                 # Built frontend files
├── deploy/
│   ├── install_dependencies.sh
│   ├── mariadb_setup.sh
│   ├── deploy_app.sh
│   ├── backup_mariadb.sh
│   ├── restore_mariadb.sh
│   └── mount_backup_volume.sh
└── logs/                     # Application logs
```

## 🔒 Security Configuration

### Firewall (Security Groups)

- **Port 22**: SSH access (restrict to your IP)
- **Port 80**: HTTP access (public)
- **Port 3306**: MariaDB (localhost only)
- **Port 8000**: FastAPI (localhost only, proxied by Nginx)

### Database Security

- Root access restricted to localhost
- Dedicated application user (`notes_user`)
- Password-protected connections
- Regular automated backups

### Application Security

- CORS configured for specific origins
- Security headers added by Nginx
- Process isolation with dedicated user
- Environment-based configuration

## 📈 Monitoring and Troubleshooting

### Health Checks

```bash
# Application health
curl http://localhost/health

# API health
curl http://localhost/api/health

# Database connectivity
mysql -u notes_user -p -e "SELECT 1;"
```

### Log Locations

```bash
# Application logs
/opt/notes_app/logs/combined.log
/opt/notes_app/logs/err.log
/opt/notes_app/logs/out.log

# Nginx logs
/var/log/nginx/access.log
/var/log/nginx/error.log

# MariaDB logs
/var/log/mariadb/mariadb.log

# Backup logs
/var/log/notes-backup.log
/backup/mariadb/backup.log
```

### Common Issues and Solutions

#### 1. Application Won't Start

```bash
# Check PM2 status
sudo -u notes_app pm2 status

# Restart PM2
sudo -u notes_app pm2 restart notes-api

# Check database connection
cd /opt/notes_app/backend
sudo -u notes_app ./venv/bin/python -c "from database_prod import test_connection; print(test_connection())"
```

#### 2. Database Connection Issues

```bash
# Verify MariaDB is running
sudo systemctl status mariadb

# Test database credentials
mysql -u notes_user -p notes_db

# Check environment variables
cat /opt/notes_app/backend/.env
```

#### 3. Nginx Issues

```bash
# Test Nginx configuration
sudo nginx -t

# Check Nginx status
sudo systemctl status nginx

# Restart Nginx
sudo systemctl restart nginx
```

#### 4. Backup Issues

```bash
# Check if backup volume is mounted
df -h /backup

# Test backup script
sudo -u notes_app /opt/notes_app/deploy/backup_mariadb.sh

# Check backup permissions
ls -la /backup/
```

## 🔄 Updates and Maintenance

### Updating the Application

```bash
# 1. Backup current database
sudo -u notes_app /opt/notes_app/deploy/backup_mariadb.sh

# 2. Stop application
sudo systemctl stop notes-app

# 3. Update code (if using git)
cd /opt/notes_app
sudo -u notes_app git pull

# 4. Update dependencies if needed
cd backend
sudo -u notes_app ./venv/bin/pip install -r requirements-prod.txt

# 5. Rebuild frontend if needed
cd ../frontend
npm run build

# 6. Start application
sudo systemctl start notes-app
```

### Database Maintenance

```bash
# Optimize database tables
mysql -u notes_user -p notes_db -e "OPTIMIZE TABLE notes;"

# Check database size
mysql -u notes_user -p -e "
SELECT 
    table_schema AS 'Database',
    ROUND(SUM(data_length + index_length) / 1024 / 1024, 2) AS 'Size (MB)'
FROM information_schema.tables 
WHERE table_schema = 'notes_db';"
```

## 📞 Support and Contributing

### Getting Help

1. Check the logs (see locations above)
2. Verify all services are running
3. Test network connectivity
4. Review security group settings

### Environment Variables

Key environment variables in `/opt/notes_app/backend/.env`:

```env
DB_USER=notes_user
DB_PASSWORD=SecurePassword123!
DB_HOST=localhost
DB_PORT=3306
DB_NAME=notes_db
ENVIRONMENT=production
```

## 🎉 Success Verification

Your deployment is successful when:

1. ✅ All services are running:
   ```bash
   sudo systemctl is-active nginx mariadb notes-app
   ```

2. ✅ Application responds:
   ```bash
   curl -s http://localhost/health | grep healthy
   ```

3. ✅ Database is accessible:
   ```bash
   mysql -u notes_user -p -e "USE notes_db; SELECT COUNT(*) FROM notes;"
   ```

4. ✅ Backups are working:
   ```bash
   ls -la /backup/mariadb/
   ```

5. ✅ Frontend loads in browser:
   - Visit: http://ec2-3-82-116-80.compute-1.amazonaws.com

## 📚 Additional Resources

- [FastAPI Documentation](https://fastapi.tiangolo.com/)
- [MariaDB Documentation](https://mariadb.org/documentation/)
- [Nginx Documentation](https://nginx.org/en/docs/)
- [PM2 Documentation](https://pm2.keymetrics.io/docs/)
- [AWS EC2 User Guide](https://docs.aws.amazon.com/ec2/)

---

**Need help?** Check the troubleshooting section or review the log files for detailed error messages.