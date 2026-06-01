#!/usr/bin/env bash
# Poll laptop lid state and re-run displays.sh when it changes.
# i3 automatically migrates workspaces off an output once it is disabled.
set -euo pipefail

state_file=$(ls /proc/acpi/button/lid/*/state 2>/dev/null | head -1)
[[ -z "$state_file" ]] && exit 0

prev=""
while :; do
  state=$(awk '{print $NF}' "$state_file" 2>/dev/null || true)
  if [[ -n "$state" && "$state" != "$prev" ]]; then
    if [[ -n "$prev" ]]; then
      "$HOME/.config/i3/displays.sh" || true
    fi
    prev="$state"
  fi
  sleep 2
done
