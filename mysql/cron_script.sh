#!/bin/bash
set -euo pipefail

PING_URL="https://hc-ping.com/50de1c98-de2e-44bf-9d77-8315a13b6609"

curl -fsS -m 10 --retry 5 -o /dev/null "${PING_URL}/start"

export TERM=dumb
export COMPOSE_INTERACTIVE_NO_CLI=1
./backup.sh 2>&1

curl -fsS -m 10 --retry 5 -o /dev/null "${PING_URL}$([ $? -ne 0 ] && echo -n /fail)"

