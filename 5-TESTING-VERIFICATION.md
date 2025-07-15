# 5️⃣ Testing & Verification

**Final step after completing 4-APPLICATION-STARTUP.md** - Test and verify your Notes app is working correctly.

## 🎯 What You'll Test
- Backend API functionality
- Frontend application features
- Database operations
- Error handling
- Performance basics

## 🧪 Complete Testing Suite

### 1. Backend API Tests

```bash
# Get your EC2 public IP
EC2_IP=$(curl -s http://checkip.amazonaws.com)
echo "Testing app at: http://$EC2_IP"

# Test health check
curl -s http://$EC2_IP/health | jq '.'

# Test API endpoints
echo "Testing GET /api/notes (should return empty array initially)"
curl -s http://$EC2_IP/api/notes | jq '.'

# Test creating a note
echo "Testing POST /api/notes"
curl -s -X POST http://$EC2_IP/api/notes \
  -H "Content-Type: application/json" \
  -d '{
    "title": "Test Note",
    "content": "This is a test note from EC2",
    "color": "yellow"
  }' | jq '.'

# Test getting notes again (should show the created note)
echo "Testing GET /api/notes (should now show 1 note)"
curl -s http://$EC2_IP/api/notes | jq '.'
```

### 2. Frontend Browser Tests

Open your browser and go to: `http://YOUR_EC2_PUBLIC_IP`

#### ✅ Visual Checks:
- [ ] Page loads without errors
- [ ] Notes app interface appears
- [ ] Search bar is visible
- [ ] "New Note" button works
- [ ] Dark theme (Catppuccin) is applied

#### ✅ Functionality Tests:
1. **Create a note:**
   - Click "New Note"
   - Add title and content
   - Select a color
   - Save note

2. **Edit a note:**
   - Click on existing note
   - Modify content
   - Save changes

3. **Search functionality:**
   - Type in search bar
   - Verify filtering works

4. **Delete a note:**
   - Hover over note
   - Click delete icon
   - Confirm deletion

### 3. Database Verification

```bash
# Check database file exists
ls -la ~/notes-app/backend/notes.db

# Check database contents (requires sqlite3)
sudo apt install sqlite3 -y

# View database structure
sqlite3 ~/notes-app/backend/notes.db ".schema"

# View all notes in database
sqlite3 ~/notes-app/backend/notes.db "SELECT * FROM notes;"
```

### 4. Log Analysis

```bash
# Check PM2 logs for errors
pm2 logs notes-backend --lines 50

# Check Nginx logs
sudo tail -f /var/log/nginx/access.log
sudo tail -f /var/log/nginx/error.log

# Check system resources
htop  # Press 'q' to quit
df -h  # Check disk usage
free -h  # Check memory usage
```

### 5. Performance Tests

```bash
# Test API response time
time curl -s http://$EC2_IP/health

# Test multiple concurrent requests
for i in {1..10}; do
  curl -s http://$EC2_IP/api/notes &
done
wait

# Check response headers
curl -I http://$EC2_IP/
```

### 6. Security Verification

```bash
# Check open ports
sudo netstat -tlnp

# Verify firewall status
sudo ufw status

# Check service permissions
ps aux | grep -E "(nginx|python)"
```

## 🎯 Load Testing (Optional)

For production readiness, test with some load:

```bash
# Install Apache Bench for load testing
sudo apt install apache2-utils -y

# Test with 100 requests, 10 concurrent
ab -n 100 -c 10 http://$EC2_IP/health

# Test API endpoint
ab -n 50 -c 5 http://$EC2_IP/api/notes
```

## 🐛 Troubleshooting Common Issues

### Backend Not Responding
```bash
# Check if backend is running
pm2 status
pm2 restart notes-backend

# Check backend logs
pm2 logs notes-backend --lines 20

# Test backend directly
curl http://localhost:8000/health
```

### Frontend Not Loading
```bash
# Check Nginx status
sudo systemctl status nginx

# Check Nginx configuration
sudo nginx -t

# Restart Nginx
sudo systemctl restart nginx

# Check if files exist
ls -la ~/notes-app/frontend/dist/
```

### Database Issues
```bash
# Check database permissions
ls -la ~/notes-app/backend/notes.db

# Reset database (CAUTION: This deletes all data)
cd ~/notes-app/backend
rm notes.db
# Restart backend to recreate
pm2 restart notes-backend
```

### CORS Issues
```bash
# Check backend CORS settings
grep -n "CORS" ~/notes-app/backend/main.py

# Update .env file with correct IP
cd ~/notes-app/backend
nano .env  # Add your EC2 IP to CORS_ORIGINS
pm2 restart notes-backend
```

## 📊 Final Verification Report

Run this comprehensive check:

```bash
echo "=== Notes App Deployment Verification ==="
echo "Date: $(date)"
echo "EC2 Instance: $(curl -s http://checkip.amazonaws.com)"
echo ""

echo "1. System Status:"
echo "   - Nginx: $(sudo systemctl is-active nginx)"
echo "   - PM2 Backend: $(pm2 jlist | jq -r '.[0].pm2_env.status' 2>/dev/null || echo 'Check manually')"
echo ""

echo "2. Network Tests:"
echo "   - Health Check: $(curl -s -o /dev/null -w "%{http_code}" http://localhost:8000/health)"
echo "   - Frontend: $(curl -s -o /dev/null -w "%{http_code}" http://localhost/)"
echo "   - API: $(curl -s -o /dev/null -w "%{http_code}" http://localhost/api/notes)"
echo ""

echo "3. Database:"
echo "   - DB File: $([ -f ~/notes-app/backend/notes.db ] && echo 'Exists' || echo 'Missing')"
echo "   - Notes Count: $(sqlite3 ~/notes-app/backend/notes.db "SELECT COUNT(*) FROM notes;" 2>/dev/null || echo 'Unable to query')"
echo ""

echo "4. Resources:"
echo "   - Disk Usage: $(df -h / | tail -1 | awk '{print $5}')"
echo "   - Memory Usage: $(free | grep Mem | awk '{printf("%.1f%%\n", $3/$2 * 100.0)}')"
echo ""

echo "=== Deployment Complete! ==="
echo "Frontend: http://$(curl -s http://checkip.amazonaws.com)/"
echo "API Docs: http://$(curl -s http://checkip.amazonaws.com)/docs"
```

## ✅ Final Checklist

- [ ] Backend API responding to all endpoints
- [ ] Frontend loads and displays correctly
- [ ] Can create, read, update, delete notes
- [ ] Search functionality works
- [ ] Database is properly initialized
- [ ] PM2 process manager running
- [ ] Nginx serving frontend correctly
- [ ] Auto-restart configured for reboots
- [ ] Logs are accessible and clean
- [ ] Security ports properly configured

## 🎉 Success!

If all tests pass, your Notes app is successfully deployed on EC2! 

**Access your app at:** `http://YOUR_EC2_PUBLIC_IP`

## 📚 Next Steps

- Set up a domain name and SSL certificate
- Configure automated backups
- Set up monitoring and alerts
- Consider using RDS for production database
- Implement CI/CD pipeline for updates