#!/usr/bin/env bash
set -euo pipefail

echo "Opening a focused on-demand NetObserv dashboard for the demo..."
oc netobserv metrics \
  --enable_filter=true \
  --protocol=TCP \
  --port=8080 \
  --cidr=0.0.0.0/0 \
  --include_list=namespace_flows_total,workload_ingress_bytes_total,node_ingress_bytes_total,node_egress_bytes_total
