#!/bin/bash

set -euo pipefail

CURRENT_DATE=$(date +"%Y-%m-%d")

# Normal backup
# These go into db_dumps.
if [ -z "${1-}" ]; then
	BACKUP_TAR_GZ_FILE="$(pwd)/db_dumps/backup-${CURRENT_DATE}.tar.gz"
else
	# If specified, this must be an absolute path.
	BACKUP_TAR_GZ_FILE="$1"
fi

doppler setup -p coursetable -c prod
docker exec db pg_dump -U postgres -d coursetable -n public > /tmp/coursetable.sql

pushd /tmp > /dev/null
tar -czf "$BACKUP_TAR_GZ_FILE" coursetable.sql
rm -f coursetable.sql
popd > /dev/null

# Delete backups older than 30 days
find $(pwd)/db_dumps/ -iname "*.tar.gz" -mtime +30 -delete
