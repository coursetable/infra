#!/bin/bash

set -euo pipefail

if [ $# -gt 0 ]; then
    BACKUP_TO_RESTORE="$1"
else
    export LATEST_BACKUP=$(ls -Art /home/app/ferry_snapshots/*.sql | tail -n 1)
    BACKUP_TO_RESTORE="/home/app/ferry_snapshots/$LATEST_BACKUP"
fi

docker exec -i db dropdb -U postgres -f ferry
docker exec -i db createdb -U postgres ferry
docker exec -i db psql -U postgres -d ferry < "$BACKUP_TO_RESTORE"
docker exec -i db psql -U postgres -d ferry < $(pwd)/hasura-user.sql
docker exec -i db psql -U postgres -d ferry < $(pwd)/ferry-user.sql
