#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "Applying Loki PoC namespaces..."
oc apply -f "${ROOT_DIR}/k8s/00-namespaces-loki.yaml"

echo "Applying build configs..."
oc apply -f "${ROOT_DIR}/k8s/10-builds-loki.yaml"

echo "Starting builds first..."
oc -n oil-loki-demo start-build oil-loki-service --from-dir="${ROOT_DIR}/app/service" --follow
oc -n oil-loki-peer start-build oil-loki-service --from-dir="${ROOT_DIR}/app/service" --follow
oc -n oil-loki-blocked start-build oil-loki-service --from-dir="${ROOT_DIR}/app/service" --follow
oc -n oil-loki-demo start-build oil-essence-loki-web --from-dir="${ROOT_DIR}/app/web" --follow

echo "Applying applications..."
oc apply -f "${ROOT_DIR}/k8s/20-apps-loki.yaml"

echo "Applying network policy..."
oc apply -f "${ROOT_DIR}/k8s/30-networkpolicies-loki.yaml"

echo "Applying Loki-backed FlowCollector..."
oc apply -f "${ROOT_DIR}/k8s/40-flowcollector-loki.yaml"

echo "Applying custom dashboard..."
oc apply -f "${ROOT_DIR}/k8s/41-flowmetrics-dashboard-loki.yaml"

echo "Applying RTT alert..."
oc apply -f "${ROOT_DIR}/k8s/42-alertingrule-rtt-loki.yaml"

echo "Waiting for rollouts..."
oc -n oil-loki-demo rollout status deploy/oil-essence-loki-web
oc -n oil-loki-demo rollout status deploy/oil-loki-same-ns
oc -n oil-loki-peer rollout status deploy/oil-loki-other-ns
oc -n oil-loki-blocked rollout status deploy/oil-loki-blocked

echo
echo "Loki PoC route:"
oc -n oil-loki-demo get route oil-essence-loki-web -o jsonpath='{.spec.host}'
echo
echo "Done."
