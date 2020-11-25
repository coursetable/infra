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
docker-compose exec -T mysql sh -c 'exec mysqldump yale_advanced_oci -uroot -p"$MYSQL_ROOT_PASSWORD"' > /tmp/yale_advanced_oci.sql

pushd /tmp > /dev/null
tar -czf "$BACKUP_TAR_GZ_FILE" yaleplus.sql yale_advanced_oci.sql
rm -f yaleplus.sql yale_advanced_oci.sql
popd > /dev/null

# Dump the worksheet_courses table every day.
WORKSHEET_DUMP_FILE="worksheets/worksheet-${CURRENT_DATE}.sql"
docker-compose exec -T mysql sh -c 'exec mysqldump yale_advanced_oci worksheet_courses -uroot -p"$MYSQL_ROOT_PASSWORD"' > ${WORKSHEET_DUMP_FILE}

