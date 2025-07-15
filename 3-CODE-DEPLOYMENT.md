# 3️⃣ Code Deployment

**Run after completing 2-SERVER-SETUP.md** - Clone and set up the Notes app on your EC2 instance.

## 🎯 What You'll Do
- Clone the repository
- Set up Python virtual environment
- Install all dependencies
- Configure environment files

## 🚀 Deployment Steps

### 1. Clone Repository
```bash
# Navigate to home directory
cd ~

# Clone your repository (replace with your actual repo URL)
git clone https://github.com/YOUR_USERNAME/YOUR_REPO_NAME.git notes-app

# Or if the repo is already cloned, navigate to it
cd notes-app
```

### 2. Backend Setup

```bash
# Navigate to backend directory
cd ~/notes-app/backend

# Create Python virtual environment
python3 -m venv venv

# Activate virtual environment
source venv/bin/activate

# Upgrade pip
pip install --upgrade pip

# Install Python dependencies
pip install -r requirements.txt
```

### 3. Frontend Setup

```bash
# Navigate to frontend directory
cd ~/notes-app/frontend

# Install Node.js dependencies
npm install

# Build production version
npm run build
```

### 4. Create Environment Configuration

```bash
# Create backend environment file
cd ~/notes-app/backend
cat > .env << 'EOF'
DATABASE_URL=sqlite:///./notes.db
SECRET_KEY=your-super-secret-key-change-this-in-production
CORS_ORIGINS=http://localhost:5173,http://YOUR_EC2_PUBLIC_IP,http://YOUR_EC2_PUBLIC_IP:5173
EOF

# Make sure to replace YOUR_EC2_PUBLIC_IP with your actual IP
# Get your EC2 public IP
curl -s http://checkip.amazonaws.com
```

### 5. Set Up Directory Structure

```bash
# Create logs directory for PM2
mkdir -p ~/notes-app/logs

# Set proper permissions
chmod -R 755 ~/notes-app
```

## 🔍 Verify Setup

### Check Backend Dependencies
```bash
cd ~/notes-app/backend
source venv/bin/activate
python -c "import fastapi, uvicorn, sqlalchemy; print('All backend dependencies installed!')"
```

### Check Frontend Build
```bash
cd ~/notes-app/frontend
ls -la dist/  # Should show built files
```

### Test Basic Backend Functionality
```bash
cd ~/notes-app/backend
source venv/bin/activate
python -c "
from main import app
from database import engine
print('Backend setup complete!')
"
```

## 📁 Final Directory Structure

Your setup should look like this:
```
~/notes-app/
├── backend/
│   ├── venv/           # Python virtual environment
│   ├── .env            # Environment variables
│   ├── requirements.txt
│   ├── main.py
│   └── ...
├── frontend/
│   ├── dist/           # Built frontend files
│   ├── package.json
│   └── ...
├── logs/               # PM2 logs directory
└── README.md
```

## ✅ Verification Checklist
- [ ] Repository cloned successfully
- [ ] Python virtual environment created
- [ ] Backend dependencies installed
- [ ] Frontend dependencies installed
- [ ] Frontend built for production
- [ ] Environment file configured
- [ ] Directory permissions set

## 🔄 Next Step
Continue to **`4-APPLICATION-STARTUP.md`** to start the application services.