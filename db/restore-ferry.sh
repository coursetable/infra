#!/bin/bash

set -euo pipefail

docker exec -i dropdb -U postgres -f ferry
docker exec -i createdb -U postgres ferry
export LATEST_BACKUP=$(ls -Art /home/app/ferry_snapshots  | tail -n 1)
docker exec -i psql -U postgres -d ferry < /home/app/ferry_snapshots/$LATEST_BACKUP
docker exec -i db psql -U postgres -d ferry < $(pwd)/hasura-user.sql
docker exec -i db psql -U postgres -d ferry < $(pwd)/ferry-user.sql