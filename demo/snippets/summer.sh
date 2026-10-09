#!/usr/bin/env bash
# "So long as men can breathe or eyes can see" -- ask the summer service.
set -euo pipefail

SUMMER_URL="${SUMMER_URL:-http://127.0.0.1:8080}"
LEASE="${LEASE:-3}"

ask() {
  local line=$1
  curl -fsS --max-time "$LEASE" "$SUMMER_URL/?line=$line" ||
    printf '%s\n' "the lease of summer is over" >&2
}

for line in 1 4 9 14; do
  case "$line" in
    1) ask "$line" | sed 's/^/  I  /' ;;
    14) ask "$line" | sed 's/^/ XIV /' ;;
    *) ask "$line" | sed 's/^/  ?  /' ;;
  esac
done

# "But thy eternal summer shall not fade"
printf 'asked at %s\n' "$(date -Is)"
