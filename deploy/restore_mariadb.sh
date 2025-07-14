#!/bin/bash

# MariaDB Restore Script
# This script restores the MariaDB database from backup

set -e

# Configuration
DB_NAME="notes_db"
DB_USER="notes_user"
DB_PASSWORD="SecurePassword123!"  # Should match mariadb_setup.sh
BACKUP_DIR="/backup/mariadb"
LOG_FILE="${BACKUP_DIR}/restore.log"

# Function to log messages
log_message() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" | tee -a "$LOG_FILE"
}

# Function to list available backups
list_backups() {
    echo "📋 Available backups:"
    ls -la "${BACKUP_DIR}"/notes_backup_*.sql.gz 2>/dev/null | awk '{print $9, $5, $6, $7, $8}' | column -t
}

# Check if backup directory exists
if [ ! -d "$BACKUP_DIR" ]; then
    echo "❌ ERROR: Backup directory $BACKUP_DIR does not exist!"
    exit 1
fi

# Check if MariaDB is running
if ! systemctl is-active --quiet mariadb; then
    echo "❌ ERROR: MariaDB is not running!"
    exit 1
fi

echo "🗄️ MariaDB Restore Utility"
echo "=========================="

# Show available backups
list_backups

echo ""
echo "Options:"
echo "1. Restore from latest backup"
echo "2. Choose specific backup file"
echo "3. Exit"
echo ""
read -p "Please select an option (1-3): " choice

case $choice in
    1)
        BACKUP_FILE="${BACKUP_DIR}/latest_backup.sql.gz"
        if [ ! -f "$BACKUP_FILE" ]; then
            echo "❌ ERROR: Latest backup not found!"
            exit 1
        fi
        ;;
    2)
        echo ""
        list_backups
        echo ""
        read -p "Enter the full path to the backup file: " BACKUP_FILE
        if [ ! -f "$BACKUP_FILE" ]; then
            echo "❌ ERROR: Backup file not found: $BACKUP_FILE"
            exit 1
        fi
        ;;
    3)
        echo "Exiting..."
        exit 0
        ;;
    *)
        echo "❌ Invalid option!"
        exit 1
        ;;
esac

echo ""
echo "⚠️  WARNING: This will replace the current database!"
echo "📁 Backup file: $BACKUP_FILE"
echo ""
read -p "Are you sure you want to continue? (yes/no): " confirm

if [ "$confirm" != "yes" ]; then
    echo "Restore cancelled."
    exit 0
fi

log_message "🚀 Starting restore from: $BACKUP_FILE"

# Create backup of current database before restore
CURRENT_BACKUP="${BACKUP_DIR}/pre_restore_backup_$(date +%Y%m%d_%H%M%S).sql"
log_message "📋 Creating backup of current database..."
mysqldump -u "$DB_USER" -p"$DB_PASSWORD" \
    --single-transaction \
    --routines \
    --triggers \
    --add-drop-database \
    --databases "$DB_NAME" > "$CURRENT_BACKUP"

if [ $? -eq 0 ]; then
    gzip "$CURRENT_BACKUP"
    log_message "✅ Current database backed up to: ${CURRENT_BACKUP}.gz"
else
    log_message "❌ Failed to backup current database!"
    exit 1
fi

# Restore from backup
log_message "🔄 Restoring database from backup..."
if [[ "$BACKUP_FILE" == *.gz ]]; then
    zcat "$BACKUP_FILE" | mysql -u "$DB_USER" -p"$DB_PASSWORD"
else
    mysql -u "$DB_USER" -p"$DB_PASSWORD" < "$BACKUP_FILE"
fi

if [ $? -eq 0 ]; then
    log_message "✅ Database restored successfully!"
    echo "✅ Database restored successfully!"
    echo "📋 Log file: $LOG_FILE"
    echo "💾 Pre-restore backup saved as: ${CURRENT_BACKUP}.gz"
else
    log_message "❌ Database restore failed!"
    echo "❌ Database restore failed! Check the log file: $LOG_FILE"
    exit 1
fi