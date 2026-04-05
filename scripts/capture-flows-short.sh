#!/usr/bin/env bash
set -euo pipefail

MAX_TIME="${MAX_TIME:-10m}"

echo "Starting short NetObserv flow capture..."
oc netobserv flows \
  --enable_rtt \
  --enable_dns \
  --protocol=TCP \
  --port=8080 \
  --action=Accept \
  --cidr=0.0.0.0/0 \
  --max-time="${MAX_TIME}" \
  --copy=always
