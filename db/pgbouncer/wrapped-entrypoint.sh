#!/bin/sh
set -e

output_file="/etc/pgbouncer/userlist.txt"
> "$output_file"

echo "\"$DB_USER\" \"$DB_ROOT_PASSWORD\"" >> "$output_file"
echo "\"$FERRY_DB_USER\" \"$FERRY_DB_PASSWORD\"" >> "$output_file"
echo "\"$HASURA_DB_USER\" \"$HASURA_DB_PASSWORD\"" >> "$output_file"

echo "Userlist generated in $output_file"
cat "$output_file"
# Run the original entrypoint
/entrypoint.sh
exec "$@"
