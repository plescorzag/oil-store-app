#!/usr/bin/env bash
set -euo pipefail

DEMO_NS="${DEMO_NS:-oil-loki-demo}"
DURATION_SEC="${DURATION_SEC:-300}"
CONCURRENCY="${CONCURRENCY:-4}"
SLEEP_BETWEEN="${SLEEP_BETWEEN:-1}"

APP_HOST="${APP_HOST:-$(oc -n "${DEMO_NS}" get route oil-essence-loki-web -o jsonpath='{.spec.host}')}"
APP_URL="http://${APP_HOST}"

echo "Demo namespace : ${DEMO_NS}"
echo "App URL        : ${APP_URL}"
echo "Duration       : ${DURATION_SEC}s"
echo "Concurrency    : ${CONCURRENCY}"
echo

if ! oc -n "${DEMO_NS}" get pod loadgen-loki >/dev/null 2>&1; then
  oc -n "${DEMO_NS}" run loadgen-loki \
    --image=registry.access.redhat.com/ubi9/ubi-minimal \
    --restart=Never \
    --command -- /bin/bash -lc 'microdnf install -y curl && sleep infinity'
  oc -n "${DEMO_NS}" wait --for=condition=Ready pod/loadgen-loki --timeout=180s
fi

END_TS=$(( $(date +%s) + DURATION_SEC ))

run_stream() {
  local idx="$1"
  oc -n "${DEMO_NS}" exec loadgen-loki -- /bin/bash -lc "
    while [ \$(date +%s) -lt ${END_TS} ]; do
      curl -sS ${APP_URL}/ >/dev/null || true
      curl -sS ${APP_URL}/api/test/fast-external >/dev/null || true
      curl -sS ${APP_URL}/api/test/slow-external >/dev/null || true
      curl -sS ${APP_URL}/api/test/missing-external >/dev/null || true
      curl -sS ${APP_URL}/api/test/same-namespace >/dev/null || true
      curl -sS ${APP_URL}/api/test/other-namespace >/dev/null || true
      curl -sS ${APP_URL}/api/test/blocked-namespace >/dev/null || true
      sleep ${SLEEP_BETWEEN}
    done
  " >/tmp/loadgen-loki-${idx}.log 2>&1 &
}

for i in $(seq 1 "${CONCURRENCY}"); do
  run_stream "${i}"
done

wait
echo "Loki PoC load generation finished."
