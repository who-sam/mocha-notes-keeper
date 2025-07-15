#!/bin/bash

# One-line EC2 deployment script for Notes app
# Usage: curl -sSL https://raw.githubusercontent.com/YOUR_USERNAME/YOUR_REPO/main/one-line-deploy.sh | bash -s YOUR_REPO_URL

set -e  # Exit on any error

REPO_URL=$1

if [ -z "$REPO_URL" ]; then
    echo "❌ Error: Please provide your repository URL"
    echo "Usage: ./one-line-deploy.sh https://github.com/YOUR_USERNAME/YOUR_REPO.git"
    exit 1
fi

echo "🚀 Starting one-line deployment of Notes app..."
echo "📦 Repo: $REPO_URL"

# Get EC2 public IP
EC2_IP=$(curl -s http://checkip.amazonaws.com)
echo "🌐 EC2 IP: $EC2_IP"

# Update system
echo "📋 Step 1: Updating system..."
sudo apt update && sudo apt upgrade -y

# Install Python 3.11
echo "📋 Step 2: Installing Python 3.11..."
sudo add-apt-repository ppa:deadsnakes/ppa -y
sudo apt update
sudo apt install python3.11 python3.11-venv python3.11-dev python3-pip -y
sudo update-alternatives --install /usr/bin/python3 python3 /usr/bin/python3.11 1

# Install Node.js
echo "📋 Step 3: Installing Node.js..."
curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -
sudo apt-get install -y nodejs

# Install tools
echo "📋 Step 4: Installing tools..."
sudo apt install git curl unzip tree htop nginx sqlite3 jq -y
sudo npm install -g pm2

# Clone repo
echo "📋 Step 5: Cloning repository..."
cd ~
git clone $REPO_URL notes-app
cd notes-app

# Setup backend
echo "📋 Step 6: Setting up backend..."
cd ~/notes-app/backend
python3 -m venv venv
source venv/bin/activate
pip install --upgrade pip
pip install -r requirements.txt

# Setup frontend
echo "📋 Step 7: Setting up frontend..."
cd ~/notes-app/frontend
npm install
npm run build

# Create environment file
echo "📋 Step 8: Creating environment file..."
cd ~/notes-app/backend
cat > .env << EOF
DATABASE_URL=sqlite:///./notes.db
SECRET_KEY=auto-generated-secret-key-$(date +%s)
CORS_ORIGINS=http://localhost:5173,http://$EC2_IP,http://$EC2_IP:5173
EOF

# Create PM2 config
echo "📋 Step 9: Creating PM2 configuration..."
cd ~/notes-app
mkdir -p logs
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

# Start backend
echo "📋 Step 10: Starting backend..."
pm2 start ecosystem.config.js

# Configure Nginx
echo "📋 Step 11: Configuring Nginx..."
sudo cat > /etc/nginx/sites-available/notes-app << 'EOF'
server {
    listen 80;
    server_name _;
    
    location / {
        root /home/ubuntu/notes-app/frontend/dist;
        index index.html;
        try_files $uri $uri/ /index.html;
        gzip on;
        gzip_types text/plain text/css application/json application/javascript text/xml application/xml application/xml+rss text/javascript;
    }
    
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

# Enable Nginx
echo "📋 Step 12: Enabling Nginx..."
sudo ln -sf /etc/nginx/sites-available/notes-app /etc/nginx/sites-enabled/
sudo rm -f /etc/nginx/sites-enabled/default
sudo nginx -t
sudo systemctl restart nginx
sudo systemctl enable nginx

# Setup auto-restart
echo "📋 Step 13: Setting up auto-restart..."
pm2 save
pm2 startup --force

# Final verification
echo "📋 Step 14: Verifying deployment..."
sleep 5

HEALTH_STATUS=$(curl -s -o /dev/null -w "%{http_code}" http://localhost:8000/health)
FRONTEND_STATUS=$(curl -s -o /dev/null -w "%{http_code}" http://localhost/)

echo ""
echo "🎉 DEPLOYMENT COMPLETE!"
echo "========================="
echo "🌐 Frontend: http://$EC2_IP/"
echo "🔧 API Docs: http://$EC2_IP/docs"
echo "❤️  Health: http://$EC2_IP/health"
echo ""
echo "📊 Status Check:"
echo "   - Backend Health: $HEALTH_STATUS (200 = ✅)"
echo "   - Frontend: $FRONTEND_STATUS (200 = ✅)"
echo "   - PM2 Status: $(pm2 list | grep notes-backend | awk '{print $12}')"
echo ""

if [ "$HEALTH_STATUS" = "200" ] && [ "$FRONTEND_STATUS" = "200" ]; then
    echo "✅ SUCCESS! Your Notes app is running at: http://$EC2_IP/"
else
    echo "⚠️  Something might be wrong. Check the logs:"
    echo "   pm2 logs notes-backend"
    echo "   sudo systemctl status nginx"
fi

echo ""
echo "🔧 Useful commands:"
echo "   pm2 status              # Check backend status"
echo "   pm2 logs notes-backend  # View backend logs"
echo "   pm2 restart notes-backend # Restart backend"
echo "   sudo systemctl restart nginx # Restart web server"