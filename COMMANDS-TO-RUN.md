# 🎯 EXACT COMMANDS TO RUN (In Order)

**THREE OPTIONS:**

## 🚀 **OPTION 1: Automated Script (Fastest)**
```bash
# One command to deploy everything (replace YOUR_REPO_URL)
curl -sSL https://raw.githubusercontent.com/YOUR_USERNAME/YOUR_REPO/main/one-line-deploy.sh | bash -s YOUR_REPO_URL
```
**Done in ~10 minutes!** ⚡

## 📋 **OPTION 2: Manual Commands (Step by Step)**
**Copy and paste these commands exactly as shown. Do NOT skip any step.**

## 📚 **OPTION 3: Detailed Guides**
**Want explanations?** → **[`0-OVERVIEW.md`](./0-OVERVIEW.md)** for detailed step-by-step guides

---

### ⚠️ PREREQUISITES 
1. Launch EC2 instance (Ubuntu 22.04) with security group allowing ports: 22, 80, 443, 8000, 5173
2. SSH into your EC2 instance  
3. Have your GitHub repo URL ready

---

## 📋 STEP 1: UPDATE SYSTEM

```bash
sudo apt update && sudo apt upgrade -y
```

---

## 📋 STEP 2: INSTALL PYTHON 3.11

```bash
sudo add-apt-repository ppa:deadsnakes/ppa -y
sudo apt update
sudo apt install python3.11 python3.11-venv python3.11-dev python3-pip -y
sudo update-alternatives --install /usr/bin/python3 python3 /usr/bin/python3.11 1
```

---

## 📋 STEP 3: INSTALL NODE.JS

```bash
curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -
sudo apt-get install -y nodejs
```

---

## 📋 STEP 4: INSTALL TOOLS

```bash
sudo apt install git curl unzip tree htop nginx sqlite3 -y
sudo npm install -g pm2
```

---

## 📋 STEP 5: CLONE YOUR REPO

**⚠️ REPLACE `YOUR_REPO_URL` WITH YOUR ACTUAL GITHUB URL**

```bash
cd ~
git clone YOUR_REPO_URL notes-app
cd notes-app
```

---

## 📋 STEP 6: SETUP BACKEND

```bash
cd ~/notes-app/backend
python3 -m venv venv
source venv/bin/activate
pip install --upgrade pip
pip install -r requirements.txt
```

---

## 📋 STEP 7: SETUP FRONTEND

```bash
cd ~/notes-app/frontend
npm install
npm run build
```

---

## 📋 STEP 8: CREATE ENVIRONMENT FILE

**⚠️ REPLACE `YOUR_EC2_PUBLIC_IP` WITH YOUR ACTUAL EC2 IP**

```bash
cd ~/notes-app/backend
cat > .env << 'EOF'
DATABASE_URL=sqlite:///./notes.db
SECRET_KEY=your-super-secret-key-change-this-in-production
CORS_ORIGINS=http://localhost:5173,http://YOUR_EC2_PUBLIC_IP,http://YOUR_EC2_PUBLIC_IP:5173
EOF
```

**Get your EC2 IP:**
```bash
curl -s http://checkip.amazonaws.com
```

---

## 📋 STEP 9: CREATE PM2 CONFIG

```bash
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
```

---

## 📋 STEP 10: START BACKEND

```bash
cd ~/notes-app
pm2 start ecosystem.config.js
pm2 status
```

---

## 📋 STEP 11: CONFIGURE NGINX

```bash
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
```

---

## 📋 STEP 12: ENABLE NGINX

```bash
sudo ln -sf /etc/nginx/sites-available/notes-app /etc/nginx/sites-enabled/
sudo rm -f /etc/nginx/sites-enabled/default
sudo nginx -t
sudo systemctl restart nginx
sudo systemctl enable nginx
```

---

## 📋 STEP 13: SETUP AUTO-RESTART

```bash
pm2 save
pm2 startup
```

**⚠️ IMPORTANT: PM2 will show you a command to run. Copy and paste that exact command (it will look like):**
```bash
sudo env PATH=$PATH:/usr/bin /usr/lib/node_modules/pm2/bin/pm2 startup systemd -u ubuntu --hp /home/ubuntu
```

---

## 📋 STEP 14: VERIFY EVERYTHING WORKS

```bash
# Check services
sudo systemctl status nginx
pm2 status

# Test backend
curl http://localhost:8000/health

# Test frontend
curl http://localhost/

# Get your public IP again
echo "Your app is at: http://$(curl -s http://checkip.amazonaws.com)/"
```

---

## ✅ FINAL TEST

**Open your browser and go to:** `http://YOUR_EC2_PUBLIC_IP`

You should see the Notes app! 🎉

---

## 🚨 IF SOMETHING BREAKS

### Backend not working:
```bash
pm2 logs notes-backend
pm2 restart notes-backend
```

### Frontend not loading:
```bash
sudo systemctl status nginx
sudo nginx -t
sudo systemctl restart nginx
```

### Check what's running:
```bash
pm2 status
sudo systemctl status nginx
```

---

## 📱 QUICK REFERENCE

- **Frontend**: `http://YOUR_EC2_IP/`
- **API Docs**: `http://YOUR_EC2_IP/docs` 
- **Backend Health**: `http://YOUR_EC2_IP/health`
- **PM2 Status**: `pm2 status`
- **PM2 Logs**: `pm2 logs notes-backend`
- **Restart Backend**: `pm2 restart notes-backend`
- **Restart Nginx**: `sudo systemctl restart nginx`