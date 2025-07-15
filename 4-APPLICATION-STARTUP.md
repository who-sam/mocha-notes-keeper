# 4️⃣ Application Startup

**Run after completing 3-CODE-DEPLOYMENT.md** - Start the Notes app with PM2 and configure Nginx.

## 🎯 What You'll Do
- Create PM2 configuration
- Start backend with PM2
- Configure Nginx for frontend
- Set up auto-restart on boot

## 🚀 Startup Steps

### 1. Create PM2 Ecosystem File

```bash
cd ~/notes-app

# Create PM2 ecosystem configuration
cat > ecosystem.config.js << 'EOF'
module.exports = {
  apps: [
    {
      name: 'notes-backend',
      script: 'main.py',
      cwd: './backend',
      interpreter: './backend/venv/bin/python',
      env: {
        PORT: 8000,
        NODE_ENV: 'production'
      },
      error_file: './logs/backend-error.log',
      out_file: './logs/backend-out.log',
      log_file: './logs/backend-combined.log',
      instances: 1,
      autorestart: true,
      watch: false,
      max_memory_restart: '1G'
    }
  ]
};
EOF
```

### 2. Start Backend with PM2

```bash
# Start the backend service
pm2 start ecosystem.config.js

# Check status
pm2 status

# View logs
pm2 logs notes-backend
```

### 3. Configure Nginx for Frontend

```bash
# Create Nginx configuration
sudo cat > /etc/nginx/sites-available/notes-app << 'EOF'
server {
    listen 80;
    server_name _;  # Replace with your domain if you have one
    
    # Frontend - serve built React app
    location / {
        root /home/ubuntu/notes-app/frontend/dist;
        index index.html;
        try_files $uri $uri/ /index.html;
        
        # Enable gzip compression
        gzip on;
        gzip_types text/plain text/css application/json application/javascript text/xml application/xml application/xml+rss text/javascript;
    }
    
    # Backend API - proxy to FastAPI
    location /api/ {
        proxy_pass http://localhost:8000;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_cache_bypass $http_upgrade;
    }
    
    # Backend docs and health check
    location ~ ^/(docs|health)$ {
        proxy_pass http://localhost:8000;
        proxy_http_version 1.1;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
}
EOF

# Enable the site
sudo ln -sf /etc/nginx/sites-available/notes-app /etc/nginx/sites-enabled/

# Remove default nginx site
sudo rm -f /etc/nginx/sites-enabled/default

# Test nginx configuration
sudo nginx -t

# Restart nginx
sudo systemctl restart nginx
sudo systemctl enable nginx
```

### 4. Set Up Auto-Restart on Boot

```bash
# Save PM2 processes
pm2 save

# Generate startup script
pm2 startup

# Follow the instructions shown by PM2 startup command
# It will show a command like: sudo env PATH=$PATH:/usr/bin pm2 startup systemd -u ubuntu --hp /home/ubuntu
# Copy and run that command
```

### 5. Final Service Status Check

```bash
# Check all services
sudo systemctl status nginx
pm2 status
pm2 logs notes-backend --lines 10

# Check if backend is responding
curl http://localhost:8000/health

# Check if everything is accessible
curl http://localhost/
```

## 🌐 Access Your Application

Your Notes app should now be accessible at:

- **Frontend**: `http://YOUR_EC2_PUBLIC_IP/`
- **Backend API**: `http://YOUR_EC2_PUBLIC_IP/api/notes`
- **API Docs**: `http://YOUR_EC2_PUBLIC_IP/docs`
- **Health Check**: `http://YOUR_EC2_PUBLIC_IP/health`

## 🔧 Useful PM2 Commands

```bash
# View application status
pm2 status

# View logs
pm2 logs notes-backend
pm2 logs notes-backend --lines 50

# Restart application
pm2 restart notes-backend

# Stop application
pm2 stop notes-backend

# Delete application
pm2 delete notes-backend

# Monitor in real-time
pm2 monit
```

## ✅ Verification Checklist
- [ ] PM2 ecosystem file created
- [ ] Backend started with PM2
- [ ] Nginx configured and running
- [ ] Auto-restart on boot configured
- [ ] All services status green
- [ ] Frontend accessible via browser
- [ ] Backend API responding
- [ ] API documentation accessible

## 🔄 Next Step
Continue to **`5-TESTING-VERIFICATION.md`** to test the complete application.