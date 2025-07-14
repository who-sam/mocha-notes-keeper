#!/bin/bash

# MariaDB Setup Script for Notes Application
# This script creates the database, user, and tables for the notes app

set -e

echo "🗄️ Setting up MariaDB for Notes Application..."

# MariaDB configuration
DB_NAME="notes_db"
DB_USER="notes_user"
DB_PASSWORD="SecurePassword123!"  # Change this in production
ROOT_PASSWORD=""  # Will be set during mysql_secure_installation

# Function to execute MySQL commands
execute_mysql() {
    mysql -u root -p"$ROOT_PASSWORD" -e "$1"
}

# Check if MariaDB is running
if ! systemctl is-active --quiet mariadb; then
    echo "⚠️ MariaDB is not running. Starting MariaDB..."
    sudo systemctl start mariadb
fi

echo "🔒 Please run 'sudo mysql_secure_installation' first if you haven't already."
echo "📝 Creating database and user..."

# Create database and user
mysql -u root -p << EOF
CREATE DATABASE IF NOT EXISTS ${DB_NAME} CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
CREATE USER IF NOT EXISTS '${DB_USER}'@'localhost' IDENTIFIED BY '${DB_PASSWORD}';
GRANT ALL PRIVILEGES ON ${DB_NAME}.* TO '${DB_USER}'@'localhost';
FLUSH PRIVILEGES;
EXIT;
EOF

echo "📋 Creating notes table..."

# Create the notes table
mysql -u root -p ${DB_NAME} << EOF
CREATE TABLE IF NOT EXISTS notes (
    id INT AUTO_INCREMENT PRIMARY KEY,
    title VARCHAR(255) NOT NULL,
    content TEXT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_created_at (created_at)
);

-- Insert sample data
INSERT INTO notes (title, content) VALUES 
('Welcome Note', 'Welcome to your Notes Application! This is your first note.'),
('Getting Started', 'You can create, edit, and delete notes using this application.')
ON DUPLICATE KEY UPDATE title=title;
EOF

echo "✅ MariaDB setup completed!"
echo "📝 Database Details:"
echo "   Database: ${DB_NAME}"
echo "   User: ${DB_USER}"
echo "   Password: ${DB_PASSWORD}"
echo ""
echo "🔧 Connection string for application:"
echo "   mysql://${DB_USER}:${DB_PASSWORD}@localhost:3306/${DB_NAME}"