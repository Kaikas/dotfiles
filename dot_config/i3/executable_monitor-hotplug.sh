#!/usr/bin/env bash
# Poll RandR connector status and re-run displays.sh when it changes.
# Catches USB-C dock plug/unplug and late-initialising outputs after boot.
# Uses xrandr (not /sys/class/drm) because the NVIDIA proprietary driver
# does not expose DisplayPort MST sub-stream connectors via sysfs.
set -euo pipefail

snapshot() {
  xrandr --query 2>/dev/null | awk '/ (connected|disconnected)( |$)/{print $1, $2}'
}

prev=$(snapshot)
while :; do
  sleep 2
  cur=$(snapshot)
  if [[ -n "$cur" && "$cur" != "$prev" ]]; then
    "$HOME/.config/i3/displays.sh" || true
    prev=$(snapshot)
  fi
done
