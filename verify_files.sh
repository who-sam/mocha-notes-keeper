#!/bin/bash

# File Verification Script
# This script verifies that all required deployment files are present

set -e

# Colors for output
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Counters
TOTAL_CHECKS=0
PASSED_CHECKS=0
FAILED_CHECKS=0

# Function to check if file exists and is executable
check_file() {
    local file=$1
    local should_be_executable=$2
    local description=$3
    
    TOTAL_CHECKS=$((TOTAL_CHECKS + 1))
    
    if [ -f "$file" ]; then
        if [ "$should_be_executable" = "true" ]; then
            if [ -x "$file" ]; then
                echo -e "✅ ${GREEN}$file${NC} - $description (executable)"
                PASSED_CHECKS=$((PASSED_CHECKS + 1))
            else
                echo -e "⚠️  ${YELLOW}$file${NC} - $description (exists but not executable)"
                echo -e "   ${YELLOW}Fix with: chmod +x $file${NC}"
                FAILED_CHECKS=$((FAILED_CHECKS + 1))
            fi
        else
            echo -e "✅ ${GREEN}$file${NC} - $description"
            PASSED_CHECKS=$((PASSED_CHECKS + 1))
        fi
    else
        echo -e "❌ ${RED}$file${NC} - $description (MISSING)"
        FAILED_CHECKS=$((FAILED_CHECKS + 1))
    fi
}

# Function to check directory
check_directory() {
    local dir=$1
    local description=$2
    
    TOTAL_CHECKS=$((TOTAL_CHECKS + 1))
    
    if [ -d "$dir" ]; then
        echo -e "✅ ${GREEN}$dir/${NC} - $description"
        PASSED_CHECKS=$((PASSED_CHECKS + 1))
    else
        echo -e "❌ ${RED}$dir/${NC} - $description (MISSING)"
        FAILED_CHECKS=$((FAILED_CHECKS + 1))
    fi
}

echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}Notes Application File Verification${NC}"
echo -e "${BLUE}========================================${NC}\n"

echo "Checking deployment files and structure...\n"

# Check main directories
echo -e "${BLUE}📁 Directories:${NC}"
check_directory "deploy" "Deployment scripts directory"
check_directory "backend" "Backend application directory"
check_directory "frontend" "Frontend application directory"

echo ""

# Check deployment scripts
echo -e "${BLUE}🔧 Deployment Scripts:${NC}"
check_file "quick_start.sh" "true" "Master deployment script"
check_file "deploy/install_dependencies.sh" "true" "System dependencies installer"
check_file "deploy/mariadb_setup.sh" "true" "MariaDB setup script"
check_file "deploy/mount_backup_volume.sh" "true" "EBS volume mount helper"
check_file "deploy/deploy_app.sh" "true" "Application deployment script"
check_file "deploy/backup_mariadb.sh" "true" "Database backup script"
check_file "deploy/restore_mariadb.sh" "true" "Database restore script"
check_file "deploy/setup_backup_cron.sh" "true" "Automated backup setup"
check_file "final_check.sh" "true" "Post-deployment validation script"
check_file "test_connection.sh" "true" "Frontend-backend connection test"

echo ""

# Check backend files
echo -e "${BLUE}🐍 Backend Files:${NC}"
check_file "backend/main.py" "false" "Development FastAPI app"
check_file "backend/main_prod.py" "false" "Production FastAPI app"
check_file "backend/database.py" "false" "Development database config"
check_file "backend/database_prod.py" "false" "Production database config"
check_file "backend/requirements.txt" "false" "Development dependencies"
check_file "backend/requirements-prod.txt" "false" "Production dependencies"
check_file "backend/.env.production" "false" "Environment template"
check_file "backend/models.py" "false" "Database models"
check_file "backend/schemas.py" "false" "Pydantic schemas"
check_file "backend/crud.py" "false" "Database operations"

echo ""

# Check API directory
echo -e "${BLUE}🔌 API Files:${NC}"
check_directory "backend/api" "API routes directory"
if [ -d "backend/api" ]; then
    check_file "backend/api/routes.py" "false" "API routes (if exists)"
fi

echo ""

# Check frontend files
echo -e "${BLUE}⚛️  Frontend Files:${NC}"
check_file "frontend/package.json" "false" "Frontend dependencies"
check_file "frontend/vite.config.ts" "false" "Vite configuration"
check_file "frontend/index.html" "false" "Main HTML file"
check_directory "frontend/src" "Frontend source directory"

echo ""

# Check documentation
echo -e "${BLUE}📚 Documentation:${NC}"
check_file "EC2_DEPLOYMENT_README.md" "false" "Main deployment guide"
check_file "AWS_SETUP_CHECKLIST.md" "false" "AWS setup checklist"
check_file "README.md" "false" "Project README"

echo ""

# Additional checks
echo -e "${BLUE}🔍 Additional Verifications:${NC}"

# Check if backend has __pycache__ (indicates Python files are valid)
if [ -d "backend/__pycache__" ]; then
    echo -e "✅ ${GREEN}backend/__pycache__/${NC} - Python bytecode (indicates valid Python files)"
else
    echo -e "ℹ️  ${YELLOW}backend/__pycache__/${NC} - Python bytecode (will be created on first run)"
fi

# Check for .gitignore
if [ -f ".gitignore" ]; then
    echo -e "✅ ${GREEN}.gitignore${NC} - Git ignore file"
else
    echo -e "⚠️  ${YELLOW}.gitignore${NC} - Git ignore file (recommended)"
fi

echo ""

# Summary
echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}Verification Summary${NC}"
echo -e "${BLUE}========================================${NC}"
echo -e "Total checks: $TOTAL_CHECKS"
echo -e "✅ Passed: ${GREEN}$PASSED_CHECKS${NC}"

if [ $FAILED_CHECKS -gt 0 ]; then
    echo -e "❌ Failed: ${RED}$FAILED_CHECKS${NC}"
    echo ""
    echo -e "${RED}⚠️  Some files are missing or not properly configured!${NC}"
    echo "Please ensure all required files are present before deployment."
    echo ""
    echo "Common fixes:"
    echo "• Make scripts executable: find deploy/ -name '*.sh' -exec chmod +x {} \\;"
    echo "• Check file paths and spellings"
    echo "• Ensure all files were uploaded to EC2 instance"
    echo ""
    exit 1
else
    echo -e "❌ Failed: ${GREEN}0${NC}"
    echo ""
    echo -e "${GREEN}🎉 All verification checks passed!${NC}"
    echo -e "${GREEN}Your deployment files are ready.${NC}"
    echo ""
    echo "Next steps:"
    echo "1. Verify AWS infrastructure (see AWS_SETUP_CHECKLIST.md)"
    echo "2. Run the deployment: sudo ./quick_start.sh"
    echo "3. Follow the guided deployment process"
    echo ""
fi

# Show file structure
echo ""
echo -e "${BLUE}📁 Project Structure:${NC}"
echo "Current working directory: $(pwd)"
echo ""
tree -L 3 -I '__pycache__|node_modules|.git|*.pyc|dist|build' . 2>/dev/null || {
    echo "Project structure (tree command not available):"
    find . -type f -not -path './.git/*' -not -path './node_modules/*' -not -path './__pycache__/*' -not -path './frontend/dist/*' | head -20
    if [ $(find . -type f -not -path './.git/*' -not -path './node_modules/*' -not -path './__pycache__/*' -not -path './frontend/dist/*' | wc -l) -gt 20 ]; then
        echo "... and more files"
    fi
}