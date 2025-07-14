#!/bin/bash

# Setup Automated Backup Cron Job
# This script sets up regular automated backups

set -e

echo "⏰ Setting up automated backup cron job..."

# Configuration
SERVICE_USER="notes_app"
APP_DIR="/opt/notes_app"
BACKUP_SCRIPT="$APP_DIR/deploy/backup_mariadb.sh"

# Check if backup script exists
if [ ! -f "$BACKUP_SCRIPT" ]; then
    echo "❌ ERROR: Backup script not found at $BACKUP_SCRIPT"
    exit 1
fi

# Make backup script executable
chmod +x "$BACKUP_SCRIPT"

echo "📋 Backup Schedule Options:"
echo "1. Daily at 2:00 AM"
echo "2. Every 6 hours"
echo "3. Every 12 hours" 
echo "4. Weekly (Sunday at 2:00 AM)"
echo "5. Custom schedule"
echo ""
read -p "Please select backup frequency (1-5): " choice

case $choice in
    1)
        CRON_SCHEDULE="0 2 * * *"
        DESCRIPTION="Daily at 2:00 AM"
        ;;
    2)
        CRON_SCHEDULE="0 */6 * * *"
        DESCRIPTION="Every 6 hours"
        ;;
    3)
        CRON_SCHEDULE="0 */12 * * *"
        DESCRIPTION="Every 12 hours"
        ;;
    4)
        CRON_SCHEDULE="0 2 * * 0"
        DESCRIPTION="Weekly on Sunday at 2:00 AM"
        ;;
    5)
        echo ""
        echo "Enter custom cron schedule (format: minute hour day month dayofweek)"
        echo "Examples:"
        echo "  0 3 * * *     (daily at 3 AM)"
        echo "  30 */4 * * *  (every 4 hours at 30 minutes past)"
        echo "  0 1 */2 * *   (every 2 days at 1 AM)"
        read -p "Enter schedule: " CRON_SCHEDULE
        DESCRIPTION="Custom: $CRON_SCHEDULE"
        ;;
    *)
        echo "❌ Invalid option!"
        exit 1
        ;;
esac

echo ""
echo "Selected schedule: $DESCRIPTION"
echo "Cron pattern: $CRON_SCHEDULE"
echo ""
read -p "Continue with this schedule? (yes/no): " confirm

if [ "$confirm" != "yes" ]; then
    echo "Setup cancelled."
    exit 0
fi

# Create cron job
echo "📅 Creating cron job..."

# Create cron job file
cat > /etc/cron.d/notes-backup << EOF
# Notes Application Database Backup
# Schedule: $DESCRIPTION
# Generated on: $(date)
SHELL=/bin/bash
PATH=/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin

$CRON_SCHEDULE $SERVICE_USER $BACKUP_SCRIPT >> /var/log/notes-backup.log 2>&1
EOF

# Set proper permissions
chmod 644 /etc/cron.d/notes-backup

# Create log file
touch /var/log/notes-backup.log
chown $SERVICE_USER:$SERVICE_USER /var/log/notes-backup.log

# Restart cron service
systemctl restart crond

echo "✅ Automated backup setup completed!"
echo ""
echo "📋 Backup Details:"
echo "=================="
echo "Schedule: $DESCRIPTION"
echo "Script: $BACKUP_SCRIPT"
echo "User: $SERVICE_USER"
echo "Log file: /var/log/notes-backup.log"
echo "Cron file: /etc/cron.d/notes-backup"
echo ""
echo "🔧 Management Commands:"
echo "======================"
echo "View cron jobs: sudo crontab -u $SERVICE_USER -l"
echo "Check backup log: sudo tail -f /var/log/notes-backup.log"
echo "Manual backup: sudo -u $SERVICE_USER $BACKUP_SCRIPT"
echo "List backups: ls -la /backup/mariadb/"
echo ""
echo "⚡ Test the backup system:"
echo "sudo -u $SERVICE_USER $BACKUP_SCRIPT"