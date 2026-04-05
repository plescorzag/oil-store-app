#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "1) Generating traffic..."
"${ROOT_DIR}/generate-load.sh" &

sleep 10

echo
echo "2) Opening on-demand metrics dashboard..."
"${ROOT_DIR}/open-on-demand-dashboard.sh"

echo
echo "3) In the OpenShift console use these views:"
echo "   - Observe -> Network Traffic -> Topology"
echo "     Scope = Resource   => pod-to-pod flow maps"
echo "     Scope = Namespace  => namespace traffic analysis"
echo
echo "   - Observe -> Dashboards -> NetObserv / Oil Essence Demo"
echo "     Show total demo flows, RTT p95, RTT average"
echo
echo "   - Observe -> Alerting"
echo "     Watch for OilEssenceDemoHighRTT when the slow path is exercised"
