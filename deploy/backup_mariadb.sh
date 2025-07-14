#!/bin/bash

# MariaDB Backup Script
# This script backs up the MariaDB database to the /backup volume

set -e

# Configuration
DB_NAME="notes_db"
DB_USER="notes_user"
DB_PASSWORD="SecurePassword123!"  # Should match mariadb_setup.sh
BACKUP_DIR="/backup/mariadb"
DATE=$(date +%Y%m%d_%H%M%S)
BACKUP_FILE="${BACKUP_DIR}/notes_backup_${DATE}.sql"
LOG_FILE="${BACKUP_DIR}/backup.log"
RETENTION_DAYS=7  # Keep backups for 7 days

echo "🗄️ Starting MariaDB backup process..."

# Create backup directory if it doesn't exist
mkdir -p "${BACKUP_DIR}"

# Function to log messages
log_message() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" | tee -a "$LOG_FILE"
}

# Check if backup directory is mounted
if ! mountpoint -q /backup; then
    log_message "❌ ERROR: /backup is not mounted!"
    echo "Please ensure the EBS volume is properly mounted at /backup"
    exit 1
fi

# Check if MariaDB is running
if ! systemctl is-active --quiet mariadb; then
    log_message "❌ ERROR: MariaDB is not running!"
    exit 1
fi

log_message "🚀 Starting backup of database: $DB_NAME"

# Create the backup
mysqldump -u "$DB_USER" -p"$DB_PASSWORD" \
    --single-transaction \
    --routines \
    --triggers \
    --add-drop-database \
    --databases "$DB_NAME" > "$BACKUP_FILE"

if [ $? -eq 0 ]; then
    # Compress the backup
    gzip "$BACKUP_FILE"
    BACKUP_FILE="${BACKUP_FILE}.gz"
    
    # Get file size
    BACKUP_SIZE=$(du -h "$BACKUP_FILE" | cut -f1)
    
    log_message "✅ Backup completed successfully!"
    log_message "📁 Backup file: $BACKUP_FILE"
    log_message "📏 Backup size: $BACKUP_SIZE"
    
    # Create a symlink to the latest backup
    ln -sf "$BACKUP_FILE" "${BACKUP_DIR}/latest_backup.sql.gz"
    log_message "🔗 Created symlink to latest backup"
    
else
    log_message "❌ Backup failed!"
    exit 1
fi

# Clean up old backups (keep only last N days)
log_message "🧹 Cleaning up old backups (keeping last $RETENTION_DAYS days)..."
find "${BACKUP_DIR}" -name "notes_backup_*.sql.gz" -type f -mtime +$RETENTION_DAYS -delete
OLD_LOGS=$(find "${BACKUP_DIR}" -name "backup.log.*" -type f -mtime +$RETENTION_DAYS)
if [ -n "$OLD_LOGS" ]; then
    echo "$OLD_LOGS" | xargs rm -f
fi

# Rotate log file if it's too large (>10MB)
if [ -f "$LOG_FILE" ] && [ $(stat -f%z "$LOG_FILE" 2>/dev/null || stat -c%s "$LOG_FILE") -gt 10485760 ]; then
    mv "$LOG_FILE" "${LOG_FILE}.$(date +%Y%m%d)"
    log_message "📋 Log file rotated"
fi

log_message "✅ Backup process completed successfully!"
echo "Backup completed! Check $LOG_FILE for details."