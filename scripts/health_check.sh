#!/usr/bin/env sh

URL="${1:-https://localhost/health.html}"

# -k : allow self-signed
# -f : fail on HTTP errors (4xx/5xx)
# -s : silent
# -S : show error if any
if curl -kfsS "$URL" >/dev/null 2>&1; then
  echo "OK: $URL"
  exit 0
else
  echo "FAIL: $URL"
  exit 1
fi
