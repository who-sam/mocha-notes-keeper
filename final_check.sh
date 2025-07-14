#!/bin/bash

# Final Deployment Validation Script
# Run this script after deployment to validate everything is working

set -e

# Colors for output
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Counters
TOTAL_CHECKS=0
PASSED_CHECKS=0
FAILED_CHECKS=0

print_header() {
    echo -e "\n${BLUE}========================================${NC}"
    echo -e "${BLUE}$1${NC}"
    echo -e "${BLUE}========================================${NC}\n"
}

print_check() {
    local name="$1"
    local command="$2"
    local success_msg="$3"
    local error_msg="$4"
    
    TOTAL_CHECKS=$((TOTAL_CHECKS + 1))
    
    if eval "$command" >/dev/null 2>&1; then
        echo -e "✅ ${GREEN}$name${NC} - $success_msg"
        PASSED_CHECKS=$((PASSED_CHECKS + 1))
    else
        echo -e "❌ ${RED}$name${NC} - $error_msg"
        FAILED_CHECKS=$((FAILED_CHECKS + 1))
    fi
}

print_header "Final Deployment Validation"

echo "Validating your Notes Application deployment..."
echo ""

# System Services Check
echo -e "${BLUE}🔧 System Services:${NC}"
print_check "Nginx" "systemctl is-active --quiet nginx" "Running and active" "Not running or failed"
print_check "MariaDB" "systemctl is-active --quiet mariadb" "Running and active" "Not running or failed" 
print_check "Notes App" "systemctl is-active --quiet notes-app" "Running and active" "Not running or failed"
print_check "PM2 Process" "sudo -u notes_app pm2 list | grep -q notes-api" "Notes API process found" "Notes API process not found"

echo ""

# Network and Connectivity
echo -e "${BLUE}🌐 Network & Connectivity:${NC}"
print_check "Port 80 Listening" "netstat -tln | grep -q ':80 '" "Nginx listening on port 80" "Port 80 not listening"
print_check "Port 8000 Listening" "netstat -tln | grep -q '127.0.0.1:8000'" "FastAPI listening on port 8000" "Port 8000 not listening"
print_check "Local Health Check" "curl -s http://localhost/health | grep -q healthy" "Health endpoint responding" "Health endpoint not responding"

echo ""

# Database Checks
echo -e "${BLUE}🗄️ Database:${NC}"
print_check "MariaDB Socket" "test -S /var/lib/mysql/mysql.sock" "Socket file exists" "Socket file missing"
print_check "Notes Database" "mysql -u notes_user -pSecurePassword123! -e 'USE notes_db; SHOW TABLES;' | grep -q notes" "Notes table exists" "Notes table missing or connection failed"
print_check "Database Connectivity" "mysql -u notes_user -pSecurePassword123! -e 'SELECT 1;'" "Database connection successful" "Database connection failed"

echo ""

# File System Checks
echo -e "${BLUE}📁 File System:${NC}"
print_check "Application Directory" "test -d /opt/notes_app" "Application directory exists" "Application directory missing"
print_check "Backup Mount" "mountpoint -q /backup" "Backup volume mounted" "Backup volume not mounted"
print_check "Virtual Environment" "test -f /opt/notes_app/backend/venv/bin/python" "Python venv exists" "Python venv missing"
print_check "Frontend Build" "test -d /opt/notes_app/frontend/dist" "Frontend built successfully" "Frontend build missing"

echo ""

# Application Specific Checks
echo -e "${BLUE}🚀 Application Features:${NC}"
print_check "API Documentation" "curl -s http://localhost/api/docs | grep -q 'Notes API'" "API docs accessible" "API docs not accessible"
print_check "Static Files" "curl -s http://localhost/ | grep -q 'Notes'" "Frontend accessible" "Frontend not accessible"
print_check "Notes API Endpoint" "curl -s http://localhost/api/notes | grep -q '\\['" "Notes API endpoint working" "Notes API endpoint not working"

echo ""

# Backup System Checks
echo -e "${BLUE}💾 Backup System:${NC}"
print_check "Backup Directory" "test -d /backup/mariadb" "Backup directory exists" "Backup directory missing"
print_check "Backup Script" "test -x /opt/notes_app/deploy/backup_mariadb.sh" "Backup script executable" "Backup script missing or not executable"
print_check "Cron Job" "test -f /etc/cron.d/notes-backup" "Backup cron job configured" "Backup cron job missing"

echo ""

# Security Checks
echo -e "${BLUE}🔐 Security:${NC}"
print_check "Service User" "id notes_app" "Application user exists" "Application user missing"
print_check "File Permissions" "test -O /opt/notes_app" "Application directory owned correctly" "Incorrect ownership"
print_check "Environment File" "test -f /opt/notes_app/backend/.env" "Environment file exists" "Environment file missing"

echo ""

# Performance Test
echo -e "${BLUE}⚡ Performance:${NC}"
echo "Testing response time..."
RESPONSE_TIME=$(curl -o /dev/null -s -w '%{time_total}' http://localhost/health)
if (( $(echo "$RESPONSE_TIME < 2.0" | bc -l) )); then
    echo -e "✅ ${GREEN}Response Time${NC} - ${RESPONSE_TIME}s (Good)"
    PASSED_CHECKS=$((PASSED_CHECKS + 1))
else
    echo -e "⚠️  ${YELLOW}Response Time${NC} - ${RESPONSE_TIME}s (Slow)"
    FAILED_CHECKS=$((FAILED_CHECKS + 1))
fi
TOTAL_CHECKS=$((TOTAL_CHECKS + 1))

# Summary
echo ""
print_header "Validation Summary"
echo -e "Total checks: $TOTAL_CHECKS"
echo -e "✅ Passed: ${GREEN}$PASSED_CHECKS${NC}"
echo -e "❌ Failed: ${RED}$FAILED_CHECKS${NC}"

if [ $FAILED_CHECKS -eq 0 ]; then
    echo ""
    echo -e "${GREEN}🎉 All checks passed! Your deployment is successful!${NC}"
    echo ""
    echo -e "${BLUE}Your Notes Application is ready to use:${NC}"
    echo "🌐 Main App: http://ec2-3-82-116-80.compute-1.amazonaws.com"
    echo "📖 API Docs: http://ec2-3-82-116-80.compute-1.amazonaws.com/api/docs"
    echo "💚 Health: http://ec2-3-82-116-80.compute-1.amazonaws.com/health"
    echo ""
    echo -e "${BLUE}Management Commands:${NC}"
    echo "• View logs: sudo -u notes_app pm2 logs"
    echo "• Restart app: sudo systemctl restart notes-app"
    echo "• Manual backup: sudo -u notes_app /opt/notes_app/deploy/backup_mariadb.sh"
elif [ $FAILED_CHECKS -le 3 ]; then
    echo ""
    echo -e "${YELLOW}⚠️  Some checks failed, but the application might still be functional.${NC}"
    echo "Please review the failed checks and troubleshoot as needed."
    echo "Refer to EC2_DEPLOYMENT_README.md for troubleshooting guide."
else
    echo ""
    echo -e "${RED}❌ Multiple checks failed. The deployment may have issues.${NC}"
    echo "Please review the deployment steps and check logs:"
    echo "• Application logs: sudo -u notes_app pm2 logs"
    echo "• System logs: sudo journalctl -u notes-app"
    echo "• Nginx logs: sudo tail -f /var/log/nginx/error.log"
    echo ""
    echo "Consider re-running: sudo ./quick_start.sh"
    exit 1
fi