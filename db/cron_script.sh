#!/bin/bash
set -euo pipefail

export TERM=dumb
export COMPOSE_INTERACTIVE_NO_CLI=1
./backup.sh 2>&1

