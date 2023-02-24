#!/bin/bash

set -euo pipefail

CURRENT_DATE=$(date +"%Y-%m-%d")

# Normal backups.
# These go into db_dumps.
# TODO: configure a retention policy. See backup-upload.sh for reference.
if [ -z "${1-}" ]; then
	BACKUP_TAR_GZ_FILE="$(pwd)/db_dumps/backups-${CURRENT_DATE}.tar.gz"
else
	# If specified, this must be an absolute path.
	BACKUP_TAR_GZ_FILE="$1"
fi

docker-compose exec -T mysql sh -c 'exec mysqldump yaleplus -uroot -p"$MYSQL_ROOT_PASSWORD"' > /tmp/yaleplus.sql

pushd /tmp > /dev/null
tar -czf "$BACKUP_TAR_GZ_FILE" yaleplus.sql
rm -f yaleplus.sql
popd > /dev/null

# Delete backups older than 30 days
find $(pwd)/db_dumps/ -iname "*.tar.gz" -mtime +30 -delete

# Dump the worksheet_courses table every day.
WORKSHEET_DUMP_FILE="worksheets/worksheet-${CURRENT_DATE}.sql"
docker-compose exec -T mysql sh -c 'exec mysqldump yaleplus WorksheetCourses -uroot -p"$MYSQL_ROOT_PASSWORD"' > ${WORKSHEET_DUMP_FILE}

# Delete worksheet_courses backups older than 30 days
find $(pwd)/worksheets/ -iname "*.sql" -mtime +30 -delete
