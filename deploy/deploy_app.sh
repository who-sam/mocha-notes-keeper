#!/bin/bash

# Complete Application Deployment Script
# This script deploys the Notes application on EC2 with MariaDB

set -e

echo "🚀 Starting Notes Application Deployment"
echo "========================================"

# Configuration
APP_DIR="/opt/notes_app"
REPO_URL="https://github.com/your-username/your-repo.git"  # Update this
SERVICE_USER="notes_app"
DOMAIN="ec2-3-82-116-80.compute-1.amazonaws.com"

# Function to print colored output
print_status() {
    echo -e "\n🔵 $1\n"
}

print_success() {
    echo -e "\n✅ $1\n"
}

print_error() {
    echo -e "\n❌ $1\n"
}

# Check if running as root
if [ "$EUID" -ne 0 ]; then
    echo "Please run this script as root (use sudo)"
    exit 1
fi

# Step 1: Copy application files
print_status "Copying application files to $APP_DIR..."
mkdir -p "$APP_DIR"
cp -r /workspace/* "$APP_DIR/"
chown -R $SERVICE_USER:$SERVICE_USER "$APP_DIR"

# Step 2: Setup Python environment
print_status "Setting up Python environment..."
cd "$APP_DIR/backend"
sudo -u $SERVICE_USER python -m venv venv
sudo -u $SERVICE_USER ./venv/bin/pip install --upgrade pip
sudo -u $SERVICE_USER ./venv/bin/pip install -r requirements-prod.txt

# Step 3: Setup environment variables
print_status "Setting up environment variables..."
if [ ! -f "$APP_DIR/backend/.env" ]; then
    sudo -u $SERVICE_USER cp .env.production .env
    # Update the .env file with correct domain
    sed -i "s/ec2-3-82-116-80.compute-1.amazonaws.com/$DOMAIN/g" "$APP_DIR/backend/.env"
fi

# Step 4: Build frontend
print_status "Building frontend..."
cd "$APP_DIR/frontend"
npm install
npm run build

# Step 5: Setup Nginx configuration
print_status "Configuring Nginx..."
cat > /etc/nginx/conf.d/notes_app.conf << EOF
server {
    listen 80;
    server_name $DOMAIN localhost;
    
    # Security headers
    add_header X-Frame-Options "SAMEORIGIN" always;
    add_header X-XSS-Protection "1; mode=block" always;
    add_header X-Content-Type-Options "nosniff" always;
    add_header Referrer-Policy "no-referrer-when-downgrade" always;
    add_header Content-Security-Policy "default-src 'self' http: https: data: blob: 'unsafe-inline'" always;
    
    # Serve frontend static files
    location / {
        root $APP_DIR/frontend/dist;
        try_files \$uri \$uri/ /index.html;
        
        # Cache static assets
        location ~* \.(js|css|png|jpg|jpeg|gif|ico|svg|woff|woff2|ttf|eot)$ {
            expires 1y;
            add_header Cache-Control "public, immutable";
        }
    }
    
    # Proxy API requests to backend
    location /api/ {
        proxy_pass http://127.0.0.1:8000;
        proxy_http_version 1.1;
        proxy_set_header Upgrade \$http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
        proxy_cache_bypass \$http_upgrade;
        
        # Timeouts
        proxy_connect_timeout 60s;
        proxy_send_timeout 60s;
        proxy_read_timeout 60s;
    }
    
    # Health check endpoint
    location /health {
        proxy_pass http://127.0.0.1:8000/api/health;
        access_log off;
    }
}
EOF

# Test nginx configuration
nginx -t
if [ $? -ne 0 ]; then
    print_error "Nginx configuration test failed!"
    exit 1
fi

# Step 6: Setup PM2 ecosystem file
print_status "Setting up PM2 configuration..."
cat > "$APP_DIR/ecosystem.config.js" << EOF
module.exports = {
    apps: [{
        name: 'notes-api',
        script: 'backend/venv/bin/python',
        args: '-m uvicorn main_prod:app --host 0.0.0.0 --port 8000',
        cwd: '$APP_DIR',
        instances: 1,
        autorestart: true,
        watch: false,
        max_memory_restart: '1G',
        env: {
            ENVIRONMENT: 'production',
            PORT: 8000,
            HOST: '0.0.0.0'
        },
        error_file: '$APP_DIR/logs/err.log',
        out_file: '$APP_DIR/logs/out.log',
        log_file: '$APP_DIR/logs/combined.log',
        time: true
    }]
};
EOF

# Create logs directory
mkdir -p "$APP_DIR/logs"
chown $SERVICE_USER:$SERVICE_USER "$APP_DIR/logs"

# Step 7: Setup systemd service for PM2
print_status "Setting up systemd service..."
cat > /etc/systemd/system/notes-app.service << EOF
[Unit]
Description=Notes Application PM2
After=network.target mariadb.service

[Service]
Type=oneshot
RemainAfterExit=yes
User=$SERVICE_USER
Group=$SERVICE_USER
WorkingDirectory=$APP_DIR
ExecStart=/usr/bin/pm2 start ecosystem.config.js
ExecStop=/usr/bin/pm2 delete notes-api
ExecReload=/usr/bin/pm2 reload ecosystem.config.js

[Install]
WantedBy=multi-user.target
EOF

# Step 8: Setup backup cron job
print_status "Setting up automatic backups..."
cat > /etc/cron.d/notes-backup << EOF
# Notes Application Database Backup
# Runs every day at 2 AM
0 2 * * * $SERVICE_USER /bin/bash $APP_DIR/deploy/backup_mariadb.sh >/dev/null 2>&1
EOF

# Set proper permissions
chmod 644 /etc/cron.d/notes-backup

# Step 9: Enable and start services
print_status "Starting services..."

# Reload systemd
systemctl daemon-reload

# Enable services
systemctl enable nginx
systemctl enable notes-app

# Start MariaDB if not running
if ! systemctl is-active --quiet mariadb; then
    systemctl start mariadb
fi

# Start services
systemctl restart nginx
systemctl start notes-app

# Step 10: Verify deployment
print_status "Verifying deployment..."

# Wait a moment for services to start
sleep 5

# Check if services are running
if systemctl is-active --quiet nginx && systemctl is-active --quiet notes-app; then
    print_success "All services are running!"
else
    print_error "Some services failed to start. Check logs:"
    echo "- Nginx: sudo systemctl status nginx"
    echo "- App: sudo systemctl status notes-app"
    echo "- PM2: sudo -u $SERVICE_USER pm2 status"
    exit 1
fi

# Test API endpoint
API_RESPONSE=$(curl -s -o /dev/null -w "%{http_code}" http://localhost:8000/api/health || echo "000")
if [ "$API_RESPONSE" = "200" ]; then
    print_success "API is responding correctly!"
else
    print_error "API is not responding. HTTP status: $API_RESPONSE"
fi

# Final status
print_success "🎉 Deployment completed successfully!"
echo ""
echo "📊 Service Status:"
echo "=================="
systemctl status nginx --no-pager -l
echo ""
systemctl status notes-app --no-pager -l
echo ""
echo "🌐 Application URLs:"
echo "==================="
echo "Frontend: http://$DOMAIN"
echo "API Docs: http://$DOMAIN/api/docs"
echo "Health Check: http://$DOMAIN/health"
echo ""
echo "📋 Management Commands:"
echo "======================"
echo "View logs: sudo -u $SERVICE_USER pm2 logs"
echo "Restart app: sudo systemctl restart notes-app"
echo "Backup DB: sudo -u $SERVICE_USER $APP_DIR/deploy/backup_mariadb.sh"
echo "Restore DB: sudo -u $SERVICE_USER $APP_DIR/deploy/restore_mariadb.sh"