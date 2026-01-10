#!/bin/bash

set -euo pipefail

# Parse date argument if provided
if [ $# -gt 0 ]; then
    if [ "$1" = "-h" ] || [ "$1" = "--help" ]; then
        usage
    fi
    
    RESTORE_DATE="$1"
    BACKUP_FILE="/home/app/ferry_snapshots/${RESTORE_DATE}.sql"
    R2_BACKUP_PATH="r2:ferry-backup/${RESTORE_DATE}.sql"
    
    # Check if backup exists locally
    if [ ! -f "$BACKUP_FILE" ]; then
        echo "Backup not found locally at $BACKUP_FILE"
        echo "Attempting to download from R2..."
        
        # Try to download from R2
        if rclone copy "$R2_BACKUP_PATH" "/home/app/ferry_snapshots/" 2>/dev/null; then
            echo "Successfully downloaded backup from R2"
        else
            echo "Error: Backup for date $RESTORE_DATE not found locally or in R2"
            echo ""
            echo "Available local backups:"
            ls -1 /home/app/ferry_snapshots/*.sql 2>/dev/null | xargs -n1 basename || echo "  (none found)"
            exit 1
        fi
    fi
    
    BACKUP_TO_RESTORE="$BACKUP_FILE"
    echo "Restoring from backup dated: $RESTORE_DATE"
else
    # Use latest backup (original behavior)
    if [ ! -d "/home/app/ferry_snapshots" ] || [ -z "$(ls -A /home/app/ferry_snapshots 2>/dev/null)" ]; then
        echo "Error: No backups found in /home/app/ferry_snapshots"
        exit 1
    fi
    
    LATEST_BACKUP=$(ls -Art /home/app/ferry_snapshots/*.sql 2>/dev/null | tail -n 1)
    if [ -z "$LATEST_BACKUP" ]; then
        echo "Error: No .sql backup files found in /home/app/ferry_snapshots"
        exit 1
    fi
    
    BACKUP_TO_RESTORE="$LATEST_BACKUP"
    BACKUP_DATE=$(basename "$LATEST_BACKUP" .sql)
    echo "Restoring from latest backup dated: $BACKUP_DATE"
fi

# Restore the database
echo "Dropping existing ferry database..."
docker exec -i db dropdb -U postgres -f ferry || true

echo "Creating new ferry database..."
docker exec -i db createdb -U postgres ferry

echo "Restoring database from backup..."
docker exec -i db psql -U postgres -d ferry < "$BACKUP_TO_RESTORE"

echo "Restoring user permissions..."
docker exec -i db psql -U postgres -d ferry < "$(pwd)/hasura-user.sql"
docker exec -i db psql -U postgres -d ferry < "$(pwd)/ferry-user.sql"

echo "Restore completed successfully!"