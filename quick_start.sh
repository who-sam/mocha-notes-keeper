#!/bin/bash

# Notes Application Quick Start Deployment Script
# This script guides you through the complete deployment process

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Functions for colored output
print_header() {
    echo -e "\n${BLUE}========================================${NC}"
    echo -e "${BLUE}$1${NC}"
    echo -e "${BLUE}========================================${NC}\n"
}

print_step() {
    echo -e "\n${GREEN}🔹 Step $1: $2${NC}\n"
}

print_warning() {
    echo -e "\n${YELLOW}⚠️  $1${NC}\n"
}

print_error() {
    echo -e "\n${RED}❌ $1${NC}\n"
}

print_success() {
    echo -e "\n${GREEN}✅ $1${NC}\n"
}

# Function to wait for user confirmation
wait_for_user() {
    echo -e "\n${YELLOW}Press Enter to continue or Ctrl+C to abort...${NC}"
    read
}

# Function to check if running as root
check_root() {
    if [ "$EUID" -ne 0 ]; then
        print_error "This script must be run as root. Please use: sudo ./quick_start.sh"
        exit 1
    fi
}

# Function to verify script exists
check_script() {
    if [ ! -f "$1" ]; then
        print_error "Required script not found: $1"
        print_error "Please ensure you have all deployment files in the correct location."
        exit 1
    fi
}

# Main deployment process
main() {
    print_header "Notes Application Quick Start Deployment"
    
    echo "This script will guide you through deploying the Notes application on your EC2 instance."
    echo "The deployment includes:"
    echo "  • System dependencies (Python, MariaDB, Nginx, etc.)"
    echo "  • Database setup and configuration"
    echo "  • Application deployment"
    echo "  • Backup volume configuration"
    echo "  • Automated backup setup"
    echo ""
    echo "Prerequisites:"
    echo "  ✓ RHEL 9 EC2 instance"
    echo "  ✓ Security groups configured (ports 22, 80)"
    echo "  ✓ EBS volume attached for backups"
    echo "  ✓ SSH access to the instance"
    
    wait_for_user
    
    # Check if we're root
    check_root
    
    # Verify all required scripts exist
    print_step "0" "Verifying deployment scripts"
    check_script "deploy/install_dependencies.sh"
    check_script "deploy/mariadb_setup.sh"
    check_script "deploy/mount_backup_volume.sh"
    check_script "deploy/deploy_app.sh"
    check_script "deploy/setup_backup_cron.sh"
    print_success "All required scripts found"
    
    # Step 1: Install dependencies
    print_step "1" "Installing system dependencies"
    echo "This will install Python 3.11, MariaDB, Node.js, Nginx, PM2 and other required packages."
    wait_for_user
    
    ./deploy/install_dependencies.sh
    print_success "System dependencies installed successfully"
    
    # Step 2: Secure MariaDB
    print_step "2" "Securing MariaDB installation"
    print_warning "You will be prompted to set a root password for MariaDB."
    print_warning "Please remember this password as you'll need it in the next step."
    echo "Recommended answers to the prompts:"
    echo "  • Set root password: YES (and set a strong password)"
    echo "  • Remove anonymous users: YES"
    echo "  • Disallow root login remotely: YES"
    echo "  • Remove test database: YES"
    echo "  • Reload privilege tables: YES"
    wait_for_user
    
    mysql_secure_installation
    print_success "MariaDB secured successfully"
    
    # Step 3: Setup database
    print_step "3" "Setting up application database"
    echo "This will create the notes database, user, and tables."
    print_warning "You will be prompted for the MariaDB root password you just set."
    wait_for_user
    
    ./deploy/mariadb_setup.sh
    print_success "Database setup completed"
    
    # Step 4: Mount backup volume
    print_step "4" "Mounting EBS backup volume"
    echo "This will help you mount your EBS volume to /backup for database backups."
    echo "You will need to:"
    echo "  • Identify your EBS volume device (e.g., /dev/xvdf)"
    echo "  • Choose filesystem type if formatting is needed"
    echo "  • Optionally add to /etc/fstab for persistent mounting"
    wait_for_user
    
    ./deploy/mount_backup_volume.sh
    print_success "Backup volume mounted successfully"
    
    # Step 5: Deploy application
    print_step "5" "Deploying the Notes application"
    echo "This will:"
    echo "  • Set up Python virtual environment"
    echo "  • Install Python dependencies"
    echo "  • Build the frontend"
    echo "  • Configure Nginx"
    echo "  • Set up PM2 and systemd services"
    echo "  • Start all services"
    wait_for_user
    
    ./deploy/deploy_app.sh
    print_success "Application deployed successfully"
    
    # Step 6: Setup automated backups
    print_step "6" "Setting up automated database backups"
    echo "This will configure automated backups of your MariaDB database."
    echo "You can choose the backup frequency (daily, every 6 hours, etc.)"
    wait_for_user
    
    ./deploy/setup_backup_cron.sh
    print_success "Automated backups configured successfully"
    
    # Final verification
    print_step "7" "Verifying deployment"
    echo "Running final verification checks..."
    
    # Check services
    echo "Checking services..."
    if systemctl is-active --quiet nginx mariadb notes-app; then
        print_success "All services are running"
    else
        print_warning "Some services may not be running properly. Check individual service status."
    fi
    
    # Test API
    echo "Testing API endpoint..."
    if curl -s http://localhost/health | grep -q "healthy"; then
        print_success "API is responding correctly"
    else
        print_warning "API may not be responding. Check application logs."
    fi
    
    # Test database
    echo "Testing database connection..."
    if mysql -u notes_user -pSecurePassword123! -e "USE notes_db; SELECT 1;" &>/dev/null; then
        print_success "Database is accessible"
    else
        print_warning "Database connection issues. Check MariaDB status and credentials."
    fi
    
    # Check backup directory
    echo "Checking backup setup..."
    if mountpoint -q /backup && [ -d "/backup/mariadb" ]; then
        print_success "Backup system is ready"
    else
        print_warning "Backup directory may not be properly configured."
    fi
    
    # Final summary
    print_header "🎉 DEPLOYMENT COMPLETED!"
    
    echo "Your Notes application has been successfully deployed!"
    echo ""
    echo "🌐 Application URLs:"
    echo "  • Main App: http://ec2-3-82-116-80.compute-1.amazonaws.com"
    echo "  • API Docs: http://ec2-3-82-116-80.compute-1.amazonaws.com/api/docs"
    echo "  • Health Check: http://ec2-3-82-116-80.compute-1.amazonaws.com/health"
    echo ""
    echo "🔧 Management Commands:"
    echo "  • View app status: sudo systemctl status notes-app"
    echo "  • View app logs: sudo -u notes_app pm2 logs"
    echo "  • Restart app: sudo systemctl restart notes-app"
    echo "  • Manual backup: sudo -u notes_app /opt/notes_app/deploy/backup_mariadb.sh"
    echo "  • Restore backup: sudo -u notes_app /opt/notes_app/deploy/restore_mariadb.sh"
    echo ""
    echo "📖 For detailed information, see: EC2_DEPLOYMENT_README.md"
    echo ""
    echo "🚀 Your Notes application is now ready to use!"
    
    # Test if we can access the application
    echo ""
    echo "Testing application accessibility..."
    DOMAIN="ec2-3-82-116-80.compute-1.amazonaws.com"
    if curl -s --max-time 10 "http://$DOMAIN" >/dev/null; then
        print_success "✅ Application is accessible from the internet!"
        echo "Visit: http://$DOMAIN"
    else
        print_warning "⚠️  Application may not be accessible from the internet yet."
        echo "This could be due to:"
        echo "  • Security group configuration"
        echo "  • DNS propagation delay" 
        echo "  • Service startup time"
        echo ""
        echo "Try accessing: http://$DOMAIN in a few minutes"
    fi
}

# Run main function
main "$@"