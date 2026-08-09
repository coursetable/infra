#!/usr/bin/env bash

set -euo pipefail

if [[ $# -eq 0 ]]; then
  echo "Usage: $0 <terraform arguments...>" >&2
  exit 64
fi

exec doppler run --project coursetable --config prod -- bash -c '
  export CLOUDFLARE_API_TOKEN="$CLOUDFLARE_TERRAFORM_API_TOKEN"
  exec terraform "$@"
' bash "$@"
