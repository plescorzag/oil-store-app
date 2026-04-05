#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "Applying namespaces..."
oc apply -f "${ROOT_DIR}/k8s/00-namespaces.yaml"

echo "Applying build configs..."
oc apply -f "${ROOT_DIR}/k8s/10-builds.yaml"

echo "Starting builds first..."
oc -n oil-demo start-build oil-demo-service --from-dir="${ROOT_DIR}/app/service" --follow
oc -n oil-peer start-build oil-demo-service --from-dir="${ROOT_DIR}/app/service" --follow
oc -n oil-blocked start-build oil-demo-service --from-dir="${ROOT_DIR}/app/service" --follow
oc -n oil-demo start-build oil-essence-web --from-dir="${ROOT_DIR}/app/web" --follow

echo "Applying applications after images exist..."
oc apply -f "${ROOT_DIR}/k8s/20-apps.yaml"

echo "Applying network policies..."
oc apply -f "${ROOT_DIR}/k8s/30-networkpolicies.yaml"

echo "Applying FlowCollector..."
oc apply -f "${ROOT_DIR}/k8s/40-flowcollector.yaml"

echo "Applying FlowMetric dashboard resources..."
oc apply -f "${ROOT_DIR}/k8s/41-flowmetrics-dashboard.yaml"

echo "Applying RTT alert rule..."
oc apply -f "${ROOT_DIR}/k8s/42-alertingrule-rtt.yaml"

echo "Waiting for rollouts..."
oc -n oil-demo rollout status deploy/oil-essence-web
oc -n oil-demo rollout status deploy/oil-same-ns
oc -n oil-peer rollout status deploy/oil-other-ns
oc -n oil-blocked rollout status deploy/oil-blocked

echo
echo "Application route:"
oc -n oil-demo get route oil-essence-web -o jsonpath='{.spec.host}'
echo
echo "Done."
