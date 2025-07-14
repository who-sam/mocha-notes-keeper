#!/bin/bash

# Mount EBS Backup Volume Script
# This script helps mount the EBS volume for backups

set -e

echo "💾 EBS Backup Volume Mount Utility"
echo "=================================="

# Function to list available block devices
list_devices() {
    echo "📋 Available block devices:"
    lsblk -f | grep -E "(NAME|disk|part)" | head -20
}

# Function to check if a device is already mounted
is_mounted() {
    if mount | grep -q "$1"; then
        return 0
    else
        return 1
    fi
}

# Show current mounts
echo "📁 Current mount points:"
df -h | grep -E "(Filesystem|/dev/)"
echo ""

# Check if /backup is already mounted
if mountpoint -q /backup; then
    echo "✅ /backup is already mounted:"
    df -h /backup
    echo ""
    read -p "Do you want to unmount and remount? (yes/no): " remount
    if [ "$remount" = "yes" ]; then
        sudo umount /backup
        echo "📤 Unmounted /backup"
    else
        echo "Exiting..."
        exit 0
    fi
fi

# List available devices
list_devices
echo ""

# Get device information
read -p "Enter the device name (e.g., /dev/xvdf, /dev/nvme1n1): " DEVICE

if [ ! -b "$DEVICE" ]; then
    echo "❌ ERROR: Device $DEVICE does not exist!"
    exit 1
fi

# Check if device is already mounted elsewhere
if is_mounted "$DEVICE"; then
    echo "⚠️  WARNING: Device $DEVICE is already mounted:"
    mount | grep "$DEVICE"
    echo ""
    read -p "Continue anyway? (yes/no): " continue_mount
    if [ "$continue_mount" != "yes" ]; then
        echo "Exiting..."
        exit 0
    fi
fi

# Check if device has a filesystem
FSTYPE=$(lsblk -f -n -o FSTYPE "$DEVICE" | head -1)

if [ -z "$FSTYPE" ]; then
    echo "📝 Device $DEVICE has no filesystem."
    echo "Available filesystem types: ext4, xfs"
    read -p "Enter filesystem type to create (ext4/xfs): " FS_CHOICE
    
    case $FS_CHOICE in
        ext4)
            echo "🔧 Creating ext4 filesystem on $DEVICE..."
            sudo mkfs.ext4 -F "$DEVICE"
            ;;
        xfs)
            echo "🔧 Creating XFS filesystem on $DEVICE..."
            sudo mkfs.xfs -f "$DEVICE"
            ;;
        *)
            echo "❌ Invalid filesystem type!"
            exit 1
            ;;
    esac
else
    echo "✅ Device $DEVICE has filesystem: $FSTYPE"
fi

# Create backup directory if it doesn't exist
sudo mkdir -p /backup

# Mount the device
echo "📁 Mounting $DEVICE to /backup..."
sudo mount "$DEVICE" /backup

if [ $? -eq 0 ]; then
    echo "✅ Successfully mounted $DEVICE to /backup"
    
    # Set permissions
    sudo chown notes_app:notes_app /backup
    sudo chmod 755 /backup
    
    # Show mount info
    df -h /backup
    
    # Add to fstab for permanent mounting
    echo ""
    read -p "Add to /etc/fstab for automatic mounting on boot? (yes/no): " add_fstab
    
    if [ "$add_fstab" = "yes" ]; then
        # Get UUID
        UUID=$(blkid -s UUID -o value "$DEVICE")
        FSTYPE=$(lsblk -f -n -o FSTYPE "$DEVICE" | head -1)
        
        if [ -n "$UUID" ]; then
            FSTAB_ENTRY="UUID=$UUID /backup $FSTYPE defaults,nofail 0 2"
            
            # Check if entry already exists
            if ! grep -q "/backup" /etc/fstab; then
                echo "$FSTAB_ENTRY" | sudo tee -a /etc/fstab
                echo "✅ Added to /etc/fstab: $FSTAB_ENTRY"
            else
                echo "⚠️  /backup entry already exists in /etc/fstab"
            fi
        else
            echo "❌ Could not get UUID for $DEVICE"
        fi
    fi
    
    echo ""
    echo "🎉 Backup volume setup completed!"
    echo "📁 Backup directory: /backup"
    echo "💾 Device: $DEVICE"
    echo "👤 Owner: notes_app"
    
else
    echo "❌ Failed to mount $DEVICE"
    exit 1
fi