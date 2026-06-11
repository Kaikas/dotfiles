#!/usr/bin/env bash
# Poll DRM connector status and re-run displays.sh when it changes.
# Catches USB-C dock plug/unplug and late-initialising outputs after boot.
set -euo pipefail

snapshot() {
  for f in /sys/class/drm/card*-*/status; do
    [[ -f "$f" ]] || continue
    printf '%s=%s\n' "$f" "$(cat "$f" 2>/dev/null || true)"
  done
}

prev=$(snapshot)
while :; do
  sleep 2
  cur=$(snapshot)
  if [[ "$cur" != "$prev" ]]; then
    "$HOME/.config/i3/displays.sh" || true
    prev=$(snapshot)
  fi
done
