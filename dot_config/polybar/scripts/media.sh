#!/usr/bin/env bash
set -euo pipefail

MAXLEN=30
ICON="󰎈 "

text="$(playerctl metadata --format "{{artist}} - {{title}}" 2>/dev/null || true)"

[[ -z "$text" ]] && exit 0

# Unicode-safe truncate
short="$(printf "%s" "$text" | cut -c1-$MAXLEN)"

if [[ "${#text}" -gt "$MAXLEN" ]]; then
  short="${short% }…"
fi

printf " %s%s " "$ICON" "$short"

